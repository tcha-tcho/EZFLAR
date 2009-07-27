/*package  {
	import com.transmote.flar.FLARMarkerEvent;
	import com.transmote.flar.FLARMarker;
	public class FLARMarkerEventPositioner extends FLARMarkerEvent {
		private var _marker:FLARMarker;
		public function FLARMarkerEventPositioner(type:String, marker:FLARMarker, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, marker, bubbles, cancelable);
			this._marker = marker;
		}
		//TCHA-TCHO IMPROVEMENTS FOR USER INTERATIONS
		public function position_x():Number{//SIDE MOVEMENT
			var xx:Number = _marker.outline.centerpoint.x;
			return xx;
		}
		public function position_y():Number{//UP AND DOWN
			var yy:Number = _marker.outline.centerpoint.y;
			return yy;
		}
		public function position_z():Number{//DEPH
			var zz:Number = _marker.transformMatrix.m23;
			return zz;
		}
		public function position_rotation_x():Number{//RIGHT TO LEFT TURNING
			var rx:Number = Math.atan2(_marker.transformMatrix.m20, _marker.transformMatrix.m22);
			return rx;
		}
		public function position_rotation_y():Number{//UP TO DOWN TURNING
			var ry:Number = Math.asin(-_marker.transformMatrix.m21);
			return ry;
		}
		public function position_rotation_z():Number{//WHEEL TURNING
			var rz:Number = Math.atan2(_marker.transformMatrix.m01, -_marker.transformMatrix.m11);
			return rz;
		}
		

	}

}
*/
