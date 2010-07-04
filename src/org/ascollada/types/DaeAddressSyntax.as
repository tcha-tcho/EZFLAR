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
 
package org.ascollada.types 
{
	import org.ascollada.utils.Logger;
	
	/**
	 * @author	Tim Knip 
	 */
	public class DaeAddressSyntax 
	{
		public var targetID:String;
		
		public var targetSID:String;
		
		public var member:String;
		
		public var arrayMember:Array;
		
		public var isArrayAccess:Boolean;
		
		public var isDotAccess:Boolean;
		
		public var isFullAccess:Boolean;
		
		/**
		 * 
		 * @return
		 */
		public function DaeAddressSyntax():void
		{
			
		}
		
		public static function parseAnimationTarget( target:String ):DaeAddressSyntax
		{
			var parts:Array;
			
			if( target.indexOf("/") == -1 )
			{
				Logger.error( "[ERROR] invalid animation target attribute!" );
				throw new Error( "invalid animation target attribute!" );
			}
			else
			{
				parts = target.split("/");
			}
			
			var syntax:DaeAddressSyntax = new DaeAddressSyntax();
			
			syntax.targetID = parts[0];
			
			parseFullMember(syntax, parts[1]);
			
			return syntax;
		}
		
		/**
		 * 
		 * @param	syntax
		 * @param	fullMember
		 * @return
		 */
		private static function parseFullMember( syntax:DaeAddressSyntax, fullMember:String ):void
		{
			syntax.isArrayAccess = syntax.isDotAccess = syntax.isFullAccess = false;
			syntax.member = "";
			syntax.arrayMember = new Array();
			
			var arrayPattern:RegExp = /\(\d\)/ig;
			
			if( arrayPattern.exec(fullMember) )
			{
				syntax.isArrayAccess = true;
				syntax.targetSID = fullMember.split("(")[0];
				syntax.arrayMember = fullMember.match(arrayPattern);
			}
			else if( fullMember.indexOf(".") != -1 )
			{
				syntax.isDotAccess = true;
				
				var dotParts:Array = fullMember.split(".");
				syntax.targetSID = dotParts[0];
				syntax.member = dotParts[1];
			}
			else if( fullMember.length )
			{
				syntax.isFullAccess = true;
				syntax.targetSID = fullMember;
			}
			else
			{
				Logger.error( "[ERROR] can't find a SID!" );
				throw new Error( "can't find a SID!" );
			}
		}
		
		public function toString():String
		{
			return "[target:" + targetID + 
				"\nSID:" + targetSID + 
				"\nmember:" + member +
				"\narrayMember:" + arrayMember + 
				"\n" + isArrayAccess + " " + isDotAccess + " " + isFullAccess
				"]";  
		}
	}	
}
