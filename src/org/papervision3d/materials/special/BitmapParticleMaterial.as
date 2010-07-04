package org.papervision3d.materials.special
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	
	import org.papervision3d.core.geom.renderables.Particle;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.draw.IParticleDrawer;

	public class BitmapParticleMaterial extends ParticleMaterial implements IParticleDrawer
	{
		
		private var scaleMatrix:Matrix;
		
		public function BitmapParticleMaterial(bitmap:BitmapData)
		{
			super(0,0);
			this.bitmap = bitmap;
			this.scaleMatrix = new Matrix();
		}
		
		override public function drawParticle(particle:Particle, graphics:Graphics, renderSessionData:RenderSessionData):void
		{
			scaleMatrix.a = particle.renderScale;
			scaleMatrix.d = particle.renderScale;	
			scaleMatrix.tx = particle.vertex3D.vertex3DInstance.x;
			scaleMatrix.ty = particle.vertex3D.vertex3DInstance.y;
			graphics.beginBitmapFill(bitmap, scaleMatrix, false, smooth);
			graphics.drawRect(particle.vertex3D.vertex3DInstance.x, particle.vertex3D.vertex3DInstance.y,particle.renderScale*particle.size,particle.renderScale*particle.size);
			graphics.endFill();
			renderSessionData.renderStatistics.particles++;
			
		}
		
	}
}