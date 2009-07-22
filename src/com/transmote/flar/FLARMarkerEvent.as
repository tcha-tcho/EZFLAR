package com.transmote.flar {
	import flash.events.Event;

	/**
	 * event with notification of a change in an active FLARMarker.
	 * contains a reference to the changed marker.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARMarkerEvent extends Event {
		public static const MARKER_ADDED:String = "markerAdded";
		public static const MARKER_UPDATED:String = "markerUpdated";
		public static const MARKER_REMOVED:String = "markerRemoved";
		
		private var _marker:FLARMarker;
		
		
		public function FLARMarkerEvent (type:String, marker:FLARMarker, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this._marker = marker;
		}
		
		public function get marker () :FLARMarker {
			return this._marker;
		}
		
		public override function clone () :Event {
			return new FLARMarkerEvent(this.type, this.marker, this.bubbles, this.cancelable);
		}
		//TCHA-TCHO IMPROVEMENTS FOR USER INTERATIONS
		public function x():Number{//SIDE MOVEMENT
			var xx:Number = _marker.outline.centerpoint.x;
			return xx;
		}
		public function y():Number{//UP AND DOWN
			var yy:Number = _marker.outline.centerpoint.y;
			return yy;
		}
		public function z():Number{//DEPH
			var zz:Number = _marker.transformMatrix.m23;
			return zz;
		}
		public function rotationX():Number{//RIGHT TO LEFT TURNING
			var rx:Number = Math.atan2(_marker.transformMatrix.m20, _marker.transformMatrix.m22);
			return rx;
		}
		public function rotationY():Number{//UP TO DOWN TURNING
			var ry:Number = Math.asin(-_marker.transformMatrix.m21);
			return ry;
		}
		public function rotationZ():Number{//WHEEL TURNING
			var rz:Number = Math.atan2(_marker.transformMatrix.m01, -_marker.transformMatrix.m11);
			return rz;
		}
	}
}