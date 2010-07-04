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
 
package org.ascollada.fx
{
	import org.ascollada.ASCollada;
	import org.ascollada.core.DaeAsset;
	import org.ascollada.core.DaeEntity;
	import org.ascollada.utils.Logger;
		
	/**
	 * 
	 */
	public class DaeMaterial extends DaeEntity
	{
		public var effect:String;
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		public function DaeMaterial( node:XML = null ):void
		{
			super( node );
		}
		
		/**
		 * 
		 * @param	node
		 * @return
		 */
		override public function read( node:XML ):void
		{			
			super.read( node );
			
			Logger.log( "reading material: " + this.id  );
			
			var assetNode:XML = getNode(node, ASCollada.DAE_ASSET_ELEMENT);
			
			if( assetNode )
				this.asset = new DaeAsset( assetNode );
			
			// get the one instance_effect
			var effectRef:XML = getNode( node, ASCollada.DAE_INSTANCE_EFFECT_ELEMENT );
			this.effect = getAttribute( effectRef, ASCollada.DAE_URL_ATTRIBUTE);
			
			Logger.log( " => effect url: " + this.effect );
			
			return;
			// get extra's
			var extraList:XMLList = getNodeList(node, ASCollada.DAE_EXTRA_ELEMENT);
			
			for each( var extra:XML in extraList )
			{
				var tec:XML = getNode( node, ASCollada.DAE_TECHNIQUE_ELEMENT );
				
				this.extras.push("extra");
				Logger.log( " => technique " + tec.attribute("profile") );
			}
		}
	}	
}
