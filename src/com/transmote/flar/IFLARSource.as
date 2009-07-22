package com.transmote.flar {
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	/**
	 * interface that defines a means of updating and accessing a
	 * BitmapData instance to be analyzed by FLARToolkit's marker detection.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public interface IFLARSource {
		function update () :void;
		function get source () :BitmapData;
		function get sourceSize () :Rectangle;
		function get downsampleRatio () :Number;
	}
}