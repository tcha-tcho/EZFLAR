/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org + blog.papervision3d.org + osflash.org/papervision3d
 */

/*
 * Copyright 2006 (c) Carlos Ulloa Matesanz, noventaynueve.com.
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

// ______________________________________________________________________
//                                               CameraObject3D: Camera3D

package org.papervision3d.cameras
{
import org.papervision3d.core.math.Matrix3D;
import org.papervision3d.core.math.Number3D;
import org.papervision3d.core.proto.CameraObject3D;
import org.papervision3d.objects.DisplayObject3D;

/**
* The Camera3D class creates a camera that views the area around a target object.
* <p/>
* A camera defines the view from which a scene will be rendered. Different camera settings would present a scene from different points of view.
* <p/>
* 3D cameras simulate still-image, motion picture, or video cameras of the real world. When rendering, the scene is drawn as if you were looking through the camera lens.
*/
public class Camera3D extends CameraObject3D
{
	// __________________________________________________________________________
	//                                                                     PUBLIC
	
	public static const TYPE:String = "CAMERA3D";
	
	/**
	* A DisplayObject3D object that specifies the current position the camera is looking at.
	*/
	public var target :DisplayObject3D;


	/**
	* A Number3D object that specifies the desired position of the camera in 3D space. Only used when calling update().
	*/
	public var goto :Number3D;

	/**
	* A Number3D object that specifies the desired rotation of the camera in 3D space. Only used when calling update().
	*/
//	public var gotoRotation :Number3D;

	/**
	* A Number3D object that specifies the desired position of the camera's target in 3D space. Only used when calling update().
	*/
//	public var gotoTarget :Number3D;

	// __________________________________________________________________________
	//                                                                      N E W
	// NN  NN EEEEEE WW    WW
	// NNN NN EE     WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE     WWW  WWW
	// NN  NN EEEEEE WW    WW

	/**
	* The Camera3D constructor creates cameras that view the area around a target object.
	*
	* Its initial position can be specified in the initObject.
	*
	* @param	zoom		This value specifies the scale at which the 3D objects are rendered. Higher values magnify the scene, compressing distance. Use it in conjunction with focus.
	* <p/>
	* @param	focus		This value is a positive number representing the distance of the observer from the front clipping plane, which is the closest any object can be to the camera. Use it in conjunction with zoom.
	* <p/>
	* @param	initObject	An optional object that contains user defined properties with which to populate the newly created DisplayObject3D.
	* <p/>
	* It includes x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY scaleZ and a user defined extra object.
	* <p/>
	* If extra is not an object, it is ignored. All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.
	* <p/>
	* The following initObject property is also recognized by the constructor:
	* <ul>
	* <li><b>sort</b>: A Boolean value that determines whether the 3D objects are z-depth sorted between themselves when rendering. The default value is true.</li>
	* </ul>
	*/
	public function Camera3D( target:DisplayObject3D=null, zoom:Number=11, focus:Number=100, initObject:Object=null )
	{
		super( zoom, focus, initObject );

		this.target = target|| DisplayObject3D.ZERO;

		this.goto = new Number3D( this.x, this.y, this.z );
//		this.goTarget = new Number3D( this.target.x, this.target.y, this.target.z );
	}

	// ___________________________________________________________________________________________________
	//                                                                                   T R A N S F O R M
	// TTTTTT RRRRR    AA   NN  NN  SSSSS FFFFFF OOOO  RRRRR  MM   MM
	//   TT   RR  RR  AAAA  NNN NN SS     FF    OO  OO RR  RR MMM MMM
	//   TT   RRRRR  AA  AA NNNNNN  SSSS  FFFF  OO  OO RRRRR  MMMMMMM
	//   TT   RR  RR AAAAAA NN NNN     SS FF    OO  OO RR  RR MM M MM
	//   TT   RR  RR AA  AA NN  NN SSSSS  FF     OOOO  RR  RR MM   MM

	/**
	* [internal-use] Transforms world coordinates into camera space.
	*/
	public override function transformView( transform:Matrix3D=null ):void
	{
		
		if(this.target){
			this.lookAt( this.target );
		}else if(this._transformDirty ){
			 updateTransform();
		}
		
		super.transformView(transform);
	}

	// ___________________________________________________________________________________________________
	//
	// UU  UU PPPPP  DDDDD    AA   TTTTTT EEEEEE
	// UU  UU PP  PP DD  DD  AAAA    TT   EE
	// UU  UU PPPPP  DD  DD AA  AA   TT   EEEE
	// UU  UU PP     DD  DD AAAAAA   TT   EE
	//  UUUU  PP     DDDDD  AA  AA   TT   EEEEEE

	/**
	* [experimental] Hovers the camera around as the user moves the mouse, without changing the distance to the target. This greatly enhances the 3D illusion.
	*
	* @param	type	Type of movement.
	* @param	mouseX	Indicates the x coordinate of the mouse position in relation to the canvas MovieClip.
	* @param	mouseY	Indicates the y coordinate of the mouse position in relation to the canvas MovieClip.
	*/
	public function hover( type:Number, mouseX:Number, mouseY:Number ):void
	{
		var target   :DisplayObject3D = this.target;
		var goto     :Number3D = this.goto;
//		var gotoTarget :Number3D = this.gotoTarget;

		var camSpeed :Number = 8;

		switch( type )
		{
			case 0:
				// Sphere mapped camera (free)
				var dX       :Number = goto.x - target.x;
				var dZ       :Number = goto.z - target.z;

				var ang      :Number = Math.atan2( dZ, dX );
				var dist     :Number = Math.sqrt( dX*dX + dZ*dZ );
				var xMouse   :Number = 0.5 * mouseX;

				var camX :Number = dist * Math.cos( ang - xMouse );
				var camZ :Number = dist * Math.sin( ang - xMouse );
				var camY :Number = goto.y - 300 * mouseY;

				this.x -= (this.x - camX) /camSpeed;
				this.y -= (this.y - camY) /camSpeed;
				this.z -= (this.z - camZ) /camSpeed;
				break;

			case 1:
				this.x -= (this.x - 1000 * mouseX) /camSpeed;
				this.y -= (this.y - 1000 * mouseY) /camSpeed;
//				this.z -= (this.z - ) /camSpeed;
				break;

/*
			// BROKEN
			case ???:
				// Sphere mapped camera (fixed)
				var dX = cam.pos.gx - cam.target.x;
				var dZ = cam.pos.gz - cam.target.z;
				ang -= ( ang - (Math.atan2( dZ, dX ) - iCanvas._xmouse/300) ) /camSpeed;
				dist -= ( dist - Math.sqrt( dX*dX + dZ*dZ ) ) /camSpeed;
				var camX = dist * Math.cos( ang );
				var camZ = dist * Math.sin( ang );
				var camY = -iCanvas._ymouse/3;

				cam.pos.x = camX;
				cam.pos.y -= (cam.pos.y - (camY + cam.pos.gy) ) /camSpeed;
				cam.pos.z = camZ;
				break;
*/
		}	
	}
	
	
	
	
	
}
}