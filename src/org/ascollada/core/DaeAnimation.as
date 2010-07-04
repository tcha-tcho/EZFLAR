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
	import org.ascollada.core.DaeChannel;
	import org.ascollada.core.DaeEntity;
	import org.ascollada.core.DaeInput;
	import org.ascollada.core.DaeSampler;
	import org.ascollada.core.DaeSource;
	import org.ascollada.utils.Logger;
	
	/**
	 * 
	 */
	public class DaeAnimation extends DaeEntity
	{	
		/** channels */
		public var channels:Array;
		
		// child animations
		public var animations:Array;
		
		/**
		 * 
		 * @param	node
		 * 
		 * @return
		 */
		public function DaeAnimation( node:XML = null ):void
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
			this.animations = new Array();
			this.channels = new Array();
			
			if( node.localName() != ASCollada.DAE_ANIMATION_ELEMENT )
				throw new Error( "expected a '" + ASCollada.DAE_ANIMATION_ELEMENT + "' element" );
				
			super.read( node );
			
			parseAnimation( node );
		}
		
		/**
		 * 
		 * @param	animationNode
		 * @return
		 */
		private function parseAnimation( node:XML ):void
		{
			var animationList:XMLList = getNodeList(node, ASCollada.DAE_ANIMATION_ELEMENT);
			var channelList:XMLList = getNodeList(node, ASCollada.DAE_CHANNEL_ELEMENT);
			var samplerList:XMLList = getNodeList(node, ASCollada.DAE_SAMPLER_ELEMENT);
			
			if( animationList.length() > 0 )
			{
				for each( var animationNode:XML in animationList )
					this.animations.push( new DaeAnimation(animationNode) );
			}
			else if( channelList.length() == 0 )
				throw new Error( "require at least one <channel> element!" );
			
			this.channels = new Array();
			
			for each( var channelNode:XML in channelList )
			{
				var channel:DaeChannel = new DaeChannel(channelNode);
				
				var samplerNode:XML = getNodeById(node, ASCollada.DAE_SAMPLER_ELEMENT, channel.source);
				var inputList:XMLList = getNodeList(samplerNode,ASCollada.DAE_INPUT_ELEMENT);
				
				var numCurves:uint = 12;
				
				for each( var inputNode:XML in inputList )
				{
					var input:DaeInput = new DaeInput( inputNode );
					var source:DaeSource = new DaeSource( getNodeById(node, ASCollada.DAE_SOURCE_ELEMENT, input.source) );
						
					var sampler:DaeSampler = new DaeSampler( samplerNode );
					
					sampler.type = input.semantic;
					sampler.values = source.values;
					
					switch( input.semantic )
					{
						case "INTERPOLATION":
							channel.interpolations = sampler.values;
							break;
							
						case "INPUT":
							channel.input = sampler.values;
							break;
							
						case "OUTPUT":
							channel.output = sampler.values;
							break;
							
						default:
							break;
					}
				}
				
				this.channels.push( channel );
			}
		}
	}
}
