/*
 * Copyright 2007 (c) Tim Knip, ascollada.org.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
 
package org.ascollada.core
{
	import org.ascollada.ASCollada;
	import org.ascollada.fx.DaeEffect;
	import org.ascollada.fx.DaeMaterial;
	import org.ascollada.namespaces.*;
	import org.ascollada.physics.DaePhysicsScene;
	import org.ascollada.utils.Logger;
	
	/**
	 * 
	 */
	public class DaeDocument extends DaeEntity
	{
		public static const X_UP:uint = 0;
		public static const Y_UP:uint = 1;
		public static const Z_UP:uint = 2;
		
		public var COLLADA:XML;
	
		public var version:String;
		
		public var animation_clips:Object;
		public var animations:Object;
		public var controllers:Object;
		public var effects:Object;
		public var images:Object;
		public var materials:Object;
		public var geometries:Object;
		public var physics_scenes:Object;
		public var visual_scenes:Object;
		public var nodes:Object;
		public var cameras:Object;
		
		public var vscene:DaeVisualScene;
		public var pscene:DaePhysicsScene;
		
		public var yUp:uint;
		
		public var materialSymbolToTarget:Object;
		public var materialTargetToSymbol:Object;
		
		/**
		 * 
		 */
		public function DaeDocument( object:Object, async:Boolean = false )
		{			
			this.COLLADA = object is XML ? object as XML : new XML( object );
			this.COLLADA.ignoreWhitespace = true;
			
			super( this.COLLADA, async );
		}
		
		public function get numQueuedAnimations():uint { return _waitingAnimations.length; }
		
		public function get numQueuedGeometries():uint { return _waitingGeometries.length; }
		
		/**
		 * 
		 * @return
		 */
		private function buildMaterialTable():void
		{
			materialSymbolToTarget = new Object();
			materialTargetToSymbol = new Object();
			
			var nodes:XMLList = this.COLLADA..collada::[ASCollada.DAE_INSTANCE_MATERIAL_ELEMENT];
			
			for each( var child:XML in nodes )
			{
				var target:String = getAttribute(child, ASCollada.DAE_TARGET_ATTRIBUTE);
				var symbol:String = getAttribute(child, ASCollada.DAE_SYMBOL_ATTRIBUTE);
				
				materialSymbolToTarget[symbol] = target;
				materialTargetToSymbol[target] = symbol;
			}
		}
		
		/**
		 * 
		 * @param	id
		 * @return
		 */
		private function findDaeNodeById( node:DaeNode, id:String, useSID:Boolean = false  ):DaeNode
		{
			if( useSID )
			{
				if( node.sid == id )
					return node;
			}
			else
			{
				if( node.id == id )
					return node;
			}
			
			for( var i:int = 0; i < node.nodes.length; i++ )
			{
				var n:DaeNode = findDaeNodeById( node.nodes[i], id, useSID );
				if( n )
					return n;
			}
			
			return null;
		}
		
		/**
		 * 
		 * @param	id
		 * @return
		 */
		public function getDaeNodeById( id:String, useSID:Boolean = false ):DaeNode
		{
			for each( var nod:DaeNode in this.nodes )
			{
				var nn:DaeNode = findDaeNodeById(nod, id, useSID);
				if( nn )
					return nn;
			}
			
			for( var i:int = 0; i < this.vscene.nodes.length; i++ )
			{				
				var node:DaeNode = this.vscene.nodes[i];
				
				var n:DaeNode = findDaeNodeById( node, id, useSID );
				
				if( n )
				{
					//Logger.log( "found '" + id + "' " + useSID + " ID:" + n.id + " Name:" + n.name + " SID:" + n.sid );
			
					return n;
				}
			}
			
			return null;
		}
		
		/**
		 * 
		 * @param	id
		 * @return
		 */
		public function getDaeNodeByIdOrSID( id:String ):DaeNode
		{
			var node:DaeNode = getDaeNodeById(id, false);
			if(!node)
				node = getDaeNodeById(id, true);
			return node;
		}
		
		/**
		 * 
		 * @return
		 */
		public function readNextAnimation():Boolean
		{
			if( _waitingAnimations.length )
			{
				try
				{
					var animation:DaeAnimation = _waitingAnimations.shift() as DaeAnimation;

					var animLib:XML = getNode(this.COLLADA, ASCollada.DAE_LIBRARY_ANIMATION_ELEMENT);
					var animNode:XML = getNodeById( animLib, ASCollada.DAE_ANIMATION_ELEMENT, animation.id );
				
					animation.read( animNode );
				}
				catch( e:Error )
				{
					Logger.error( "[ERROR] DaeDocument#readNextAnimation : " + e.toString() );
				}
				return true;
			}
			else
				return false;
		}
		
		/**
		 * 
		 * @return
		 */
		public function readNextGeometry():Boolean
		{
			if( _waitingGeometries.length )
			{
				try
				{
					var geometry:DaeGeometry = _waitingGeometries.shift() as DaeGeometry;

					var geomLib:XML = getNode(this.COLLADA, ASCollada.DAE_LIBRARY_GEOMETRY_ELEMENT);
					var geomNode:XML = getNodeById( geomLib, ASCollada.DAE_GEOMETRY_ELEMENT, geometry.id );
				
					geometry.async = false;
					
					geometry.read( geomNode );
					
					this.geometries[ geometry.id ] = geometry;
				}
				catch( e:Error )
				{
					Logger.error( "[ERROR] DaeDocument#readNextGeometry : " + e.toString() );
				}
				return true;
			}
			else
				return false;
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		override public function read( node:XML ):void
		{
			this.version = node.attribute(ASCollada.DAE_VERSION_ATTRIBUTE).toString();
			
			Logger.log( "version: " + this.version );
			
			// required!
			this.asset = new DaeAsset( getNode(this.COLLADA, ASCollada.DAE_ASSET_ELEMENT) );
			
			Logger.log( "author: " + this.asset.contributors[0].author );
			Logger.log( "created: " + this.asset.created );
			Logger.log( "modified: " + this.asset.modified );
			Logger.log( "y-up: " + this.asset.yUp );
			Logger.log( "unit_meter: " + this.asset.unit_meter );
			Logger.log( "unit_name: " + this.asset.unit_name );
			
			if( this.asset.yUp == ASCollada.DAE_Y_UP )
				this.yUp = Y_UP;
			else
				this.yUp = Z_UP;
			
			buildMaterialTable();
			
			readLibAnimationClips();
			readLibCameras();
			readLibControllers();
			readLibAnimations();
			readLibImages();
			readLibMaterials();
			readLibEffects();
			readLibGeometries(this.async);
			readLibNodes();
			readLibPhysicsScenes();
			readLibVisualScenes();
			
			readScene();
		}

		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibAnimations():void
		{
			_waitingAnimations = new Array();
			this.animations = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_ANIMATION_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_ANIMATION_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeAnimation = new DaeAnimation();
					ent.id = item.attribute(ASCollada.DAE_ID_ATTRIBUTE).toString();
					this.animations[ ent.id ] = ent;
					//Logger.log( "reading animation: " + ent.id );
					_waitingAnimations.push( ent );
				}
			}
		}

		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibAnimationClips():void
		{
			this.animation_clips = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_ANIMATION_CLIP_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_ANIMCLIP_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeAnimationClip = new DaeAnimationClip( item );
					this.animation_clips[ ent.id ] = ent;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibCameras():void
		{
			this.cameras = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_CAMERA_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_CAMERA_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeCamera = new DaeCamera( item );
					this.cameras[ ent.id ] = ent;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibControllers():void
		{
			this.controllers = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_CONTROLLER_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_CONTROLLER_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeController = new DaeController( item );
					this.controllers[ ent.id ] = ent;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibEffects():void
		{
			this.effects = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_EFFECT_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_EFFECT_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeEffect = new DaeEffect( item );
					this.effects[ ent.id ] = ent;
				}
			}
		}
		
		/**
		 * 
		 * @param	async
		 * @return
		 */
		private function readLibGeometries( async:Boolean = false ):void
		{
			_waitingGeometries = new Array();
			this.geometries = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_GEOMETRY_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_GEOMETRY_ELEMENT );
				for each( var item:XML in list )
				{
					var geometry:DaeGeometry = new DaeGeometry( item, async );
					if( async )
						_waitingGeometries.push( geometry );
					else
						this.geometries[ geometry.id ] = geometry;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibImages():void
		{
			this.images = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_IMAGE_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_IMAGE_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeImage = new DaeImage( item );
					this.images[ ent.id ] = ent;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibMaterials():void
		{
			this.materials = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_MATERIAL_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_MATERIAL_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeMaterial = new DaeMaterial( item );
					this.materials[ ent.id ] = ent;
				}
			}
		}

		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibNodes():void
		{
			this.nodes = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_NODE_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_NODE_ELEMENT );
				for each( var item:XML in list )
				{
					var node:DaeNode = new DaeNode( item );
					this.nodes[ node.id ] = node;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibPhysicsScenes():void
		{
			this.physics_scenes = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_PSCENE_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_PHYSICS_SCENE_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaePhysicsScene = new DaePhysicsScene( item );
					this.physics_scenes[ ent.id ] = ent;
				}
			}
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		private function readLibVisualScenes():void
		{
			this.visual_scenes = new Object();
			var library:XML = getNode( this.COLLADA, ASCollada.DAE_LIBRARY_VSCENE_ELEMENT );
			if( library )
			{
				var list:XMLList = getNodeList( library, ASCollada.DAE_VSCENE_ELEMENT );
				for each( var item:XML in list )
				{
					var ent:DaeVisualScene = new DaeVisualScene( item, yUp );
					this.visual_scenes[ ent.id ] = ent;
					this.vscene = ent;
				}
			}
		}
		
		/**
		 * 
		 * @return
		 */
		private function readScene():void
		{
			// try to find a valid scene...
			var sceneNode:XML = getNode( this.COLLADA, ASCollada.DAE_SCENE_ELEMENT );
			if( sceneNode )
			{
				var vsceneNode:XML = getNode( sceneNode, ASCollada.DAE_INSTANCE_VSCENE_ELEMENT );
				if( vsceneNode )
				{
					var vurl:String = getAttribute( vsceneNode, ASCollada.DAE_URL_ATTRIBUTE );
					if( this.visual_scenes[vurl] is DaeVisualScene )
					{
						Logger.log( "found visual scene: " + vurl );
						
						this.vscene = this.visual_scenes[ vurl ];
						
						Logger.log( " -> frameRate: " + this.vscene.frameRate );
						Logger.log( " -> startTime: " + this.vscene.startTime );
						Logger.log( " -> endTime: " + this.vscene.endTime );
					}
				}
				
				var psceneNode:XML = getNode( sceneNode, ASCollada.DAE_INSTANCE_PHYSICS_SCENE_ELEMENT );
				if( psceneNode )
				{
					var purl:String = getAttribute( psceneNode, ASCollada.DAE_URL_ATTRIBUTE );
					if( this.physics_scenes[purl] is DaePhysicsScene )
					{
						Logger.log( "found physics scene: " + purl );
						this.pscene = this.physics_scenes[ purl ];
					}
				}
			}
		}
		
		private var _waitingAnimations:Array;
		
		private var _waitingGeometries:Array;
	}	
}
