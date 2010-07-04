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
 
package org.ascollada.io
{
	import flash.errors.ScriptTimeoutError;
	import flash.events.Event;
	import flash.events.EventDispatcher
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import org.ascollada.core.DaeDocument;
	import org.ascollada.utils.Logger;
	
	/**
	 * 
	 */
	public class DaeReader extends EventDispatcher
	{
		public var document:DaeDocument;
		
		public var async:Boolean;
		
		/**
		 * 
		 */
		public function DaeReader( async:Boolean = false )
		{
			this.async = async;
			
			_animTimer = new Timer(100);
			_animTimer.addEventListener( TimerEvent.TIMER, loadNextAnimation );
			_geomTimer = new Timer(100);
			_geomTimer.addEventListener( TimerEvent.TIMER, loadNextGeometry );
		}
		
		/**
		 * 
		 * @param	filename
		 */
		public function read( filename:String ):void
		{
			Logger.log( "reading: " + filename );
			
			if( _animTimer.running )
				_animTimer.stop();
				
			var loader:URLLoader = new URLLoader();
			loader.addEventListener( Event.COMPLETE, completeHandler,false, 0, true );
			loader.addEventListener( ProgressEvent.PROGRESS, progressHandler,false, 0, true );
			loader.addEventListener( IOErrorEvent.IO_ERROR, handleIOError,false, 0, true );
			loader.load( new URLRequest(filename) );
		}
		
		/**
		 * 
		 * @return
		 */
		public function readAnimations():void
		{
			if( this.document.numQueuedAnimations > 0 )
			{
				Logger.log( "START READING #" +this.document.numQueuedAnimations+" ANIMATIONS" );
				_animTimer.repeatCount = this.document.numQueuedAnimations + 1;
				_animTimer.delay = 100;
				_animTimer.start();
			}
			else
				Logger.log( "NO ANIMATIONS" );
		}
		
		/**
		 * 
		 * @return
		 */
		public function readGeometries():void
		{
			if( this.document.numQueuedGeometries > 0 )
			{
				Logger.log( "START READING #" +this.document.numQueuedGeometries+" GEOMETRIES" );
				_geomTimer.repeatCount = this.document.numQueuedGeometries + 1;
				_geomTimer.delay = 100;
				_geomTimer.start();
			}
			else
				Logger.log( "NO GEOMETRIES" );
		}
		
		/**
		 * 
		 * @param	data
		 * @return
		 */
		public function loadDocument( data:* ):DaeDocument
		{
			this.document = new DaeDocument( data, this.async );
			
			_numAnimations = this.document.numQueuedAnimations;
			_numGeometries = this.document.numQueuedGeometries;
			
			dispatchEvent( new Event(Event.COMPLETE) );	
			
			return this.document;
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function completeHandler( event:Event ):void
		{
			var loader:URLLoader = event.target as URLLoader;
			
			Logger.log( "complete!" );

			loadDocument( loader.data );
		}
		
		private function progressHandler( event:ProgressEvent ):void
		{
			dispatchEvent(event);
		}
		
		private function handleIOError( event:IOErrorEvent ):void
		{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loadNextAnimation( event:TimerEvent ):void
		{
			if( !this.document.readNextAnimation() )
			{				
				_animTimer.stop();
				dispatchEvent( new Event(Event.COMPLETE) );
			}
			else
			{
				dispatchEvent( new ProgressEvent(ProgressEvent.PROGRESS, false, false, _numAnimations - this.document.numQueuedAnimations, _numAnimations) );
			}
		}
		
		/**
		 * 
		 * @param	event
		 * @return
		 */
		private function loadNextGeometry( event:TimerEvent ):void
		{
			if( !this.document.readNextGeometry() )
			{
				Logger.log( "geometries complete" );
				
				_geomTimer.stop();
				dispatchEvent( new Event(Event.COMPLETE) );
			}
			else
			{
				Logger.log( "reading next geometry" );
				dispatchEvent( new ProgressEvent(ProgressEvent.PROGRESS, false, false, _numGeometries - this.document.numQueuedGeometries, _numGeometries) );
			}
		}
		
		private var _numAnimations:uint; 
		
		private var _numGeometries:uint;
		
		private var _animTimer:Timer; 
		
		private var _geomTimer:Timer; 
	}	
}
