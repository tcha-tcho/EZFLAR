package org.papervision3d.render
{
	/* Author Rick Seeler
	*/
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.render.data.RenderStatistics;
	import org.papervision3d.core.render.command.RenderTriangle;
	import flash.display.Sprite;
	import org.papervision3d.core.render.command.RenderableListItem;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.view.layer.ViewportLayer;
	import org.papervision3d.core.render.material.MaterialManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import org.papervision3d.materials.ColorMaterial;
	import org.papervision3d.materials.BitmapMaterial;
	import flash.geom.Matrix;
	import flash.display.GraphicsBitmapFill;
	import flash.display.GraphicsEndFill;
	import flash.display.GraphicsSolidFill;
	import flash.display.GraphicsTrianglePath;
	import flash.display.TriangleCulling;
	import flash.display.IGraphicsData;
	import __AS3__.vec.Vector;
	import flash.display.GraphicsStroke;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;

	public class AstroRenderEngine extends BasicRenderEngine
	{
		public function AstroRenderEngine()
		{
			super();
		}
		
		override protected function doRender(renderSessionData:RenderSessionData, layers:Array = null):RenderStatistics
		{
			stopWatch.reset();
			stopWatch.start();
			
			//Update Materials.
			MaterialManager.getInstance().updateMaterialsBeforeRender(renderSessionData);

			//Filter the list
			filter.filter(renderList);
			
			//Sort entire list.
			sorter.sort(renderList);
			
			var rc:RenderableListItem;
			var viewport:Viewport3D = renderSessionData.viewPort;
			var vpl:ViewportLayer;

			var g:Graphics = renderSessionData.container.graphics;
			g.clear();
			var prevColor:Number = NaN;
			var prevAlpha:Number = NaN;
			var prevBitmap:BitmapData = null;
			var graphicsData:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			var vertices:Vector.<Number> = new Vector.<Number>();
			var uvtData:Vector.<Number> = new Vector.<Number>();
			var indicies:Vector.<int> = new Vector.<int>();
			var useUV:Boolean = false;
			var useT:Boolean = false;

			while(rc = renderList.pop())
			{				
				vpl = viewport.accessLayerFor(rc, true);
				var rt:RenderTriangle = rc as RenderTriangle;

				if (rt)
					renderTriangle(rt.triangle);
				else
					rc.render(renderSessionData, vpl.graphicsChannel);

				viewport.lastRenderList.push(rc);
				vpl.processRenderItem(rc);
			}

			closeOutTriangles();
			g.drawGraphicsData(graphicsData);

			//Update Materials
			MaterialManager.getInstance().updateMaterialsAfterRender(renderSessionData);
			
			renderSessionData.renderStatistics.renderTime = stopWatch.stop();
			renderSessionData.viewPort.updateAfterRender(renderSessionData);
			return renderStatistics;

			function renderTriangle(tri:Triangle3D):void 			
			{
				renderSessionData.renderStatistics.triangles++;
				if (tri.material.bitmap)
				{
					if (tri.material.bitmap != prevBitmap)
					{
						//Setup for new Bitmap material...
						closeOutTriangles();
						prevBitmap = tri.material.bitmap;
						prevColor = NaN;
						prevAlpha = NaN;
						graphicsData.push(new GraphicsBitmapFill(prevBitmap, null, tri.material.tiled, tri.material.smooth));
					}
				}
				else
				{
					if (tri.material.fillAlpha != prevAlpha || tri.material.fillColor != prevColor)
					{
						//Handle solid color materials...
						closeOutTriangles();
						prevBitmap = null;
						prevColor = tri.material.fillColor;
						prevAlpha = tri.material.fillAlpha;
						graphicsData.push(new GraphicsSolidFill(prevColor, prevAlpha));
					}
				}
				//Handle line graphics...
				if (tri.material.lineAlpha)
					graphicsData.push(new GraphicsStroke(tri.material.lineThickness, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.ROUND, 3.0, new GraphicsSolidFill(tri.material.lineColor, tri.material.lineAlpha)));
				
				if (prevBitmap && tri.uv0)
				{
					useUV = true;
					if (tri.material is BitmapMaterial)
						useT = (tri.material as BitmapMaterial).precise;
				}
				addVertex(tri.v0.vertex3DInstance.x, tri.v0.vertex3DInstance.y, tri.material.maxU, tri.material.maxV, (useUV ? tri.uv0.u : NaN), (useUV ? (1 - tri.uv0.v) : NaN), (useT ? tri.v0.vertex3DInstance.z : NaN));
				addVertex(tri.v1.vertex3DInstance.x, tri.v1.vertex3DInstance.y, tri.material.maxU, tri.material.maxV, (useUV ? tri.uv1.u : NaN), (useUV ? (1 - tri.uv1.v) : NaN), (useT ? tri.v1.vertex3DInstance.z : NaN));
				addVertex(tri.v2.vertex3DInstance.x, tri.v2.vertex3DInstance.y, tri.material.maxU, tri.material.maxV, (useUV ? tri.uv2.u : NaN), (useUV ? (1 - tri.uv2.v) : NaN), (useT ? tri.v2.vertex3DInstance.z : NaN));				
			}
			
			function closeOutTriangles():void
			{
				if (vertices.length)
				{
					//Close out the previous triangles...
					graphicsData.push(new GraphicsTrianglePath(vertices, indicies, (uvtData.length ? uvtData : null), TriangleCulling.POSITIVE));
					vertices = new Vector.<Number>();
					uvtData = new Vector.<Number>();
					indicies = new Vector.<int>();
					useUV = false;
					useT = false;
				}
			}
			
			function addVertex(x:Number, y:Number, maxU:Number, maxV:Number, u:Number, v:Number, screenZ:Number):void
			{
				var foundIndex:int = -1;
				var t:Number = NaN;
				//Calculate the 't' value...
				if (!isNaN(screenZ))
					t = renderSessionData.camera.focus / (renderSessionData.camera.focus + screenZ);
				var uvtElementsPerNode:int = (!isNaN(u) ? (!isNaN(t) ? 3 : 2) : 0);

				//Update the U and V values based on the maxU and maxV...
				if (uvtElementsPerNode)
				{
					u = u * maxU;
					v = v * maxV;
				}
					
				//See if this vertex is already in the vertices array...
				//we walk through the array backward since we are most likely to get a hit near the end of the list...
				for (var index:int = (vertices.length / 2 - 1); index >= 0 ; index--)
				{
					if (x == vertices[index * 2] &&
						y == vertices[index * 2 + 1])
					{
						if (uvtElementsPerNode && ((u != uvtData[index * uvtElementsPerNode]) || (v != uvtData[index * uvtElementsPerNode + 1])))
							continue;
							
						if (!useT || (t == uvtData[index * uvtElementsPerNode + 2]))
						{
							foundIndex = index;
							break;
						}
					}		
				}

				if (foundIndex != -1)
				{
					//Is it, so just add an index to it...
					indicies.push(foundIndex);
				}					
				else
				{
					//Nope, not there...add a new vertex and uvt elements...
					indicies.push(vertices.length / 2);
					vertices.push(x);
					vertices.push(y);
					if (uvtElementsPerNode)
					{
						uvtData.push(u);
						uvtData.push(v);
						if (!isNaN(t))
							uvtData.push(t);
					}
				}
			}
		}
	}
}