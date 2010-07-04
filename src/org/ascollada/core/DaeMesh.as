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
 
package org.ascollada.core {
	
	import org.ascollada.ASCollada;
	import org.ascollada.utils.Logger;
	
	/**
	 * 
	 */
	public class DaeMesh extends DaeEntity {
		
		/** vertices */
		public var vertices:Array;
		
		/** */
		public var sources:Object;
		
		/** */
		public var primitives:Array;
		
		/**
		 * 
		 * @param	node
		 */
		public function DaeMesh( node:XML = null ) {
			super( node )
		}
		
		/**
		 * 
		 * @return
		 */
		override public function read( node:XML ):void {
			if( node.localName() != ASCollada.DAE_MESH_ELEMENT && node.localName() != ASCollada.DAE_CONVEX_MESH_ELEMENT )
				throw new Error( "expected a '" + ASCollada.DAE_MESH_ELEMENT + " or a '" + ASCollada.DAE_CONVEX_MESH_ELEMENT + "' element" );
				
			super.read( node );
		
			this.sources = new Object();
			this.primitives = new Array();
			
			// fetch all <source> elements
			var sourceList:XMLList = getNodeList( node, ASCollada.DAE_SOURCE_ELEMENT );
			var sourceNode:XML;
			var source:DaeSource;
			
			for each( sourceNode in sourceList ) {
				source = new DaeSource( sourceNode );
				this.sources[ source.id ] = source.values;
			}
			
			// fetch <vertices> element
			var verticesNode:XML = getNode(node, ASCollada.DAE_VERTICES_ELEMENT);
			var verticesElement:DaeVertices = new DaeVertices(verticesNode);
			
			for each( var input:DaeInput in verticesElement.inputs ) {
				if( input.semantic == "POSITION" ) {
					this.vertices = sources[ input.source ];
					this.sources[ verticesElement.id ] = sources[ input.source ];
				}
			}	
			
			var children:XMLList = node.children();
			var numChildren:int = children.length();
			
			for( var i:int = 0; i < numChildren; i++ ) {
				var child:XML = children[i];
				
				switch( String(child.localName()) ) {
					case ASCollada.DAE_TRIANGLES_ELEMENT:
					case ASCollada.DAE_TRIFANS_ELEMENT:
					case ASCollada.DAE_TRISTRIPS_ELEMENT:
					case ASCollada.DAE_LINESTRIPS_ELEMENT:
					case ASCollada.DAE_LINES_ELEMENT:
					case ASCollada.DAE_POLYGONS_ELEMENT:
					case ASCollada.DAE_POLYLIST_ELEMENT:
						this.primitives.push( new DaePrimitive(this, child) );
						break;
					default:
						break;
				}
			}
		}
	}
}
