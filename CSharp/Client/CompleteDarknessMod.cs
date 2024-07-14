using System;
using System.Reflection;
using Barotrauma;
using HarmonyLib;
using Microsoft.Xna.Framework;

using Microsoft.Xna.Framework.Graphics;
using System.Collections.Generic;
using System.Linq;
using System;
using Barotrauma.Items.Components;
using Barotrauma.Extensions;
using System.Threading;

using Barotrauma.Lights;

      // patching this method https://github.com/evilfactory/LuaCsForBarotrauma/blob/5e89e2ea118cb5dbafa3214227ed2eaf57a77901/Barotrauma/BarotraumaClient/ClientSource/Map/Lights/LightManager.cs#L246
namespace CompleteDarkness
{
  class CompleteDarknessMod : IAssemblyPlugin
  {
    public Harmony harmony;
    public void Initialize()
    {
      harmony = new Harmony("nohalo.mod");

      harmony.Patch(
        original: typeof(Barotrauma.Lights.LightManager).GetMethod("RenderLightMap"),
        prefix: new HarmonyMethod(typeof(CompleteDarknessMod).GetMethod("RenderLightMap"))
      );
    }
    public void OnLoadCompleted() { }
    public void PreInitPatching() { }

    public void Dispose()
    {
      harmony.UnpatchAll();
      harmony = null;
    }

    public static bool RenderLightMap(GraphicsDevice graphics, SpriteBatch spriteBatch, Camera cam, Barotrauma.Lights.LightManager __instance, RenderTarget2D backgroundObstructor = null)
    {
            Barotrauma.Lights.LightManager _ = __instance;
            if (!_.LightingEnabled) { return true; }

            if (Math.Abs(_.currLightMapScale - GameSettings.CurrentConfig.Graphics.LightMapScale) > 0.01f)
            {
                //lightmap scale has changed -> recreate render targets
                _.CreateRenderTargets(graphics);
            }

            Matrix spriteBatchTransform = cam.Transform * Matrix.CreateScale(new Vector3(GameSettings.CurrentConfig.Graphics.LightMapScale, GameSettings.CurrentConfig.Graphics.LightMapScale, 1.0f));
            Matrix transform = cam.ShaderTransform
                * Matrix.CreateOrthographic(GameMain.GraphicsWidth, GameMain.GraphicsHeight, -1, 1) * 0.5f;

            bool highlightsVisible = _.UpdateHighlights(graphics, spriteBatch, spriteBatchTransform, cam);

            Rectangle viewRect = cam.WorldView;
            viewRect.Y -= cam.WorldView.Height;
            //check which lights need to be drawn
            _.recalculationCount = 0;
            _.activeLights.Clear();
            foreach (LightSource light in _.lights)
            {
                if (!light.Enabled) { continue; }
                if ((light.Color.A < 1 || light.Range < 1.0f) && !light.LightSourceParams.OverrideLightSpriteAlpha.HasValue) { continue; }

                if (light.ParentBody != null)
                {
                    light.ParentBody.UpdateDrawPosition();

                    Vector2 pos =  light.ParentBody.DrawPosition;
                    if (light.ParentSub != null) { pos -= light.ParentSub.DrawPosition; }
                    light.Position = pos;
                }

                //above the top boundary of the level (in an inactive respawn shuttle?)
                if (Level.Loaded != null && light.WorldPosition.Y > Level.Loaded.Size.Y) { continue; }

                float range = light.LightSourceParams.TextureRange;
                if (light.LightSprite != null)
                {
                    float spriteRange = Math.Max(
                        light.LightSprite.size.X * light.SpriteScale.X * (0.5f + Math.Abs(light.LightSprite.RelativeOrigin.X - 0.5f)),
                        light.LightSprite.size.Y * light.SpriteScale.Y * (0.5f + Math.Abs(light.LightSprite.RelativeOrigin.Y - 0.5f)));

                    float targetSize = Math.Max(light.LightTextureTargetSize.X, light.LightTextureTargetSize.Y);
                    range = Math.Max(Math.Max(spriteRange, targetSize), range);
                }
                if (!MathUtils.CircleIntersectsRectangle(light.WorldPosition, range, viewRect)) { continue; }

                light.Priority = lightPriority(range, light);

                int i = 0;
                while (i < _.activeLights.Count && light.Priority < _.activeLights[i].Priority)
                {
                    i++;
                }
                _.activeLights.Insert(i, light);
            }
            Barotrauma.Lights.LightManager.ActiveLightCount = _.activeLights.Count;

            float lightPriority(float range, LightSource light)
            {
                return
                    range *
                    ((Character.Controlled?.Submarine != null && light.ParentSub == Character.Controlled?.Submarine) ? 2.0f : 1.0f) *
                    (light.CastShadows ? 10.0f : 1.0f) *
                    (light.LightSourceParams.OverrideLightSpriteAlpha ?? (light.Color.A / 255.0f)) *
                    light.PriorityMultiplier;
            }

            //find the lights with an active light volume
            _.activeLightsWithLightVolume.Clear();
            foreach (var activeLight in _.activeLights)
            {
                if (activeLight.Range < 1.0f || activeLight.Color.A < 1 || activeLight.CurrentBrightness <= 0.0f) { continue; }
                _.activeLightsWithLightVolume.Add(activeLight);
            }

            //remove some lights with a light volume if there's too many of them
            if (_.activeLightsWithLightVolume.Count > GameSettings.CurrentConfig.Graphics.VisibleLightLimit && Screen.Selected is { IsEditor: false })
            {
                for (int i = GameSettings.CurrentConfig.Graphics.VisibleLightLimit; i < _.activeLightsWithLightVolume.Count; i++)
                {
                    _.activeLights.Remove(_.activeLightsWithLightVolume[i]);
                }
            }
            _.activeLights.Sort((l1, l2) => l1.LastRecalculationTime.CompareTo(l2.LastRecalculationTime));

            //draw light sprites attached to characters
            //render into a separate rendertarget using alpha blending (instead of on top of everything else with alpha blending)
            //to prevent the lights from showing through other characters or other light sprites attached to the same character
            //---------------------------------------------------------------------------------------------------
            graphics.SetRenderTarget(_.LimbLightMap);
            graphics.Clear(Color.Black);
            graphics.BlendState = BlendState.NonPremultiplied;
            spriteBatch.Begin(SpriteSortMode.BackToFront, BlendState.NonPremultiplied, transformMatrix: spriteBatchTransform);
            foreach (LightSource light in _.activeLights)
            {
                if (light.IsBackground || light.CurrentBrightness <= 0.0f) { continue; }
                //draw limb lights at this point, because they were skipped over previously to prevent them from being obstructed
                if (light.ParentBody?.UserData is Limb limb && !limb.Hide) { light.DrawSprite(spriteBatch, cam); }
            }
            spriteBatch.End();

            //draw background lights
            //---------------------------------------------------------------------------------------------------
            graphics.SetRenderTarget(_.LightMap);
            graphics.Clear(_.AmbientLight);
            graphics.BlendState = BlendState.Additive;
            spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.Additive, transformMatrix: spriteBatchTransform);
            Level.Loaded?.BackgroundCreatureManager?.DrawLights(spriteBatch, cam);
            foreach (LightSource light in _.activeLights)
            {
                if (!light.IsBackground || light.CurrentBrightness <= 0.0f) { continue; }
                light.DrawLightVolume(spriteBatch, _.lightEffect, transform, _.recalculationCount < Barotrauma.Lights.LightManager.MaxLightVolumeRecalculationsPerFrame, ref _.recalculationCount);
                light.DrawSprite(spriteBatch, cam);
            }
            GameMain.ParticleManager.Draw(spriteBatch, true, null, Barotrauma.Particles.ParticleBlendState.Additive);
            spriteBatch.End();

            //draw a black rectangle on hulls to hide background lights behind subs
            //---------------------------------------------------------------------------------------------------

            spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.Opaque, transformMatrix: spriteBatchTransform);
            Dictionary<Hull, Rectangle> visibleHulls = _.GetVisibleHulls(cam);
            foreach (KeyValuePair<Hull, Rectangle> hull in visibleHulls)
            {
                GUI.DrawRectangle(spriteBatch,
                    new Vector2(hull.Value.X, -hull.Value.Y),
                    new Vector2(hull.Value.Width, hull.Value.Height),
                    hull.Key.AmbientLight == Color.TransparentBlack ? Color.Black : hull.Key.AmbientLight.Multiply(hull.Key.AmbientLight.A / 255.0f), true);
            }
            spriteBatch.End();

            spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.Additive, transformMatrix: spriteBatchTransform);
            Vector3 glowColorHSV = ToolBox.RGBToHSV(_.AmbientLight);
            glowColorHSV.Z = Math.Max(glowColorHSV.Z, 0.4f);
            Color glowColor = ToolBoxCore.HSVToRGB(glowColorHSV.X, glowColorHSV.Y, glowColorHSV.Z);
            Vector2 glowSpriteSize = new Vector2(_.gapGlowTexture.Width, _.gapGlowTexture.Height);
            foreach (var gap in Gap.GapList)
            {
                if (gap.IsRoomToRoom || gap.Open <= 0.0f || gap.ConnectedWall == null) { continue; }

                float a = MathHelper.Lerp(0.5f, 1.0f,
                    PerlinNoise.GetPerlin((float)Timing.TotalTime * 0.05f, gap.GlowEffectT));

                float scale = MathHelper.Lerp(0.5f, 2.0f,
                    PerlinNoise.GetPerlin((float)Timing.TotalTime * 0.01f, gap.GlowEffectT));

                float rot = PerlinNoise.GetPerlin((float)Timing.TotalTime * 0.001f, gap.GlowEffectT) * MathHelper.TwoPi;

                Vector2 spriteScale = new Vector2(gap.Rect.Width, gap.Rect.Height) / glowSpriteSize;
                Vector2 drawPos = new Vector2(gap.DrawPosition.X, -gap.DrawPosition.Y);

                spriteBatch.Draw(_.gapGlowTexture,
                    drawPos,
                    null,
                    glowColor * a,
                    rot,
                    glowSpriteSize / 2,
                    scale: Math.Max(spriteScale.X, spriteScale.Y) * scale,
                    SpriteEffects.None,
                    layerDepth: 0);
            }
            spriteBatch.End();

            GameMain.GameScreen.DamageEffect.CurrentTechnique = GameMain.GameScreen.DamageEffect.Techniques["StencilShaderSolidColor"];
            GameMain.GameScreen.DamageEffect.Parameters["solidColor"].SetValue(Color.Black.ToVector4());
            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.NonPremultiplied, SamplerState.LinearWrap, transformMatrix: spriteBatchTransform, effect: GameMain.GameScreen.DamageEffect);
            Submarine.DrawDamageable(spriteBatch, GameMain.GameScreen.DamageEffect);
            spriteBatch.End();

            graphics.BlendState = BlendState.Additive;

            //draw the focused item and character to highlight them,
            //and light sprites (done before drawing the actual light volumes so we can make characters obstruct the highlights and sprites)
            //---------------------------------------------------------------------------------------------------
            spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.Additive, transformMatrix: spriteBatchTransform);
            foreach (LightSource light in _.activeLights)
            {
                //don't draw limb lights at this point, they need to be drawn after lights have been obstructed by characters
                if (light.IsBackground || light.ParentBody?.UserData is Limb || light.CurrentBrightness <= 0.0f) { continue; }
                light.DrawSprite(spriteBatch, cam);
            }
            spriteBatch.End();

            if (highlightsVisible)
            {
                spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.Additive);
                spriteBatch.Draw(_.HighlightMap, Vector2.Zero, Color.White);
                spriteBatch.End();
            }

            //draw characters to obstruct the highlighted items/characters and light sprites
            //---------------------------------------------------------------------------------------------------
            if (cam.Zoom > Barotrauma.Lights.LightManager.ObstructLightsBehindCharactersZoomThreshold)
            {
                _.SolidColorEffect.CurrentTechnique = _.SolidColorEffect.Techniques["SolidVertexColor"];
                spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.NonPremultiplied, effect: _.SolidColorEffect, transformMatrix: spriteBatchTransform);
                DrawCharacters(spriteBatch, cam, drawDeformSprites: false);
                spriteBatch.End();

                DeformableSprite.Effect.CurrentTechnique = DeformableSprite.Effect.Techniques["DeformShaderSolidVertexColor"];
                DeformableSprite.Effect.CurrentTechnique.Passes[0].Apply();
                spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.NonPremultiplied, transformMatrix: spriteBatchTransform);
                DrawCharacters(spriteBatch, cam, drawDeformSprites: true);
                spriteBatch.End();
            }

            static void DrawCharacters(SpriteBatch spriteBatch, Camera cam, bool drawDeformSprites)
            {
                foreach (Character character in Character.CharacterList)
                {
                    if (character.CurrentHull == null || !character.Enabled || !character.IsVisible || character.InvisibleTimer > 0.0f) { continue; }
                    if (Character.Controlled?.FocusedCharacter == character) { continue; }
                    Color lightColor = character.CurrentHull.AmbientLight == Color.TransparentBlack ?
                        Color.Black :
                        character.CurrentHull.AmbientLight.Multiply(character.CurrentHull.AmbientLight.A / 255.0f).Opaque();
                    foreach (Limb limb in character.AnimController.Limbs)
                    {
                        if (drawDeformSprites == (limb.DeformSprite == null)) { continue; }
                        limb.Draw(spriteBatch, cam, lightColor);
                    }
                    foreach (var heldItem in character.HeldItems)
                    {
                        heldItem.Draw(spriteBatch, editing: false, overrideColor: Color.Black);
                    }
                }
            }

            DeformableSprite.Effect.CurrentTechnique = DeformableSprite.Effect.Techniques["DeformShader"];
            graphics.BlendState = BlendState.Additive;

            //draw the actual light volumes, additive particles, hull ambient lights and the halo around the player
            //---------------------------------------------------------------------------------------------------
            spriteBatch.Begin(SpriteSortMode.Deferred, BlendState.Additive, transformMatrix: spriteBatchTransform);

            spriteBatch.Draw(_.LimbLightMap, new Rectangle(cam.WorldView.X, -cam.WorldView.Y, cam.WorldView.Width, cam.WorldView.Height), Color.White);

            foreach (ElectricalDischarger discharger in ElectricalDischarger.List)
            {
                discharger.DrawElectricity(spriteBatch);
            }

            foreach (LightSource light in _.activeLights)
            {
                if (light.IsBackground || light.CurrentBrightness <= 0.0f) { continue; }
                light.DrawLightVolume(spriteBatch, _.lightEffect, transform, _.recalculationCount < Barotrauma.Lights.LightManager.MaxLightVolumeRecalculationsPerFrame, ref _.recalculationCount);
            }

            if (ConnectionPanel.ShouldDebugDrawWiring)
            {
                foreach (MapEntity e in (Submarine.VisibleEntities ?? MapEntity.MapEntityList))
                {
                    if (e is Item item && !item.HiddenInGame && item.GetComponent<Wire>() is Wire wire)
                    {
                        wire.DebugDraw(spriteBatch, alpha: 0.4f);
                    }
                }
            }

            _.lightEffect.World = transform;

            GameMain.ParticleManager.Draw(spriteBatch, false, null, Barotrauma.Particles.ParticleBlendState.Additive);
            //----------------------- Code removed by Heelge -----------------------
/*             if (Character.Controlled != null)
            {
                DrawHalo(Character.Controlled);
            }
            else
            {
                foreach (Character character in Character.CharacterList)
                {
                    if (character.Submarine == null || character.IsDead || !character.IsHuman) { continue; }
                    DrawHalo(character);
                }
            }

            void DrawHalo(Character character)
            {
                if (character == null || character.Removed) { return; }
                Vector2 haloDrawPos = character.DrawPosition;
                haloDrawPos.Y = -haloDrawPos.Y;

                //ambient light decreases the brightness of the halo (no need for a bright halo if the ambient light is bright enough)
                float ambientBrightness = (AmbientLight.R + AmbientLight.B + AmbientLight.G) / 255.0f / 3.0f;
                Color haloColor = Color.White.Multiply(0.3f - ambientBrightness);
                if (haloColor.A > 0)
                {
                    float scale = 512.0f / LightSource.LightTexture.Width;
                    spriteBatch.Draw(
                        LightSource.LightTexture, haloDrawPos, null, haloColor, 0.0f,
                        new Vector2(LightSource.LightTexture.Width, LightSource.LightTexture.Height) / 2, scale, SpriteEffects.None, 0.0f);
                }
            } */
            //----------------------------------------------------------------------

            spriteBatch.End();

            //draw the actual light volumes, additive particles, hull ambient lights and the halo around the player
            //---------------------------------------------------------------------------------------------------

            graphics.SetRenderTarget(null);
            graphics.BlendState = BlendState.NonPremultiplied;
            return false;
    }
  }
}