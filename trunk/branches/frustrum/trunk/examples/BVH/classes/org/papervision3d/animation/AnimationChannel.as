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
 * Copyright 2006-2007 (c) Carlos Ulloa Matesanz, noventaynueve.com.
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
 
package org.papervision3d.animation 
{

	import org.papervision3d.Papervision3D;
	import org.papervision3d.animation.curves.*;
	import org.papervision3d.core.*;
	import org.papervision3d.objects.DisplayObject3D;
	
	/**
	 * @author Tim Knip 
	 */
	public class AnimationChannel 
	{		
		public var target:DisplayObject3D;
		
		public var curves:Array;
		
		/**
		 * 
		 * @return
		 */
		public function AnimationChannel( target:DisplayObject3D ):void
		{
			this.target = target;
			this.curves = new Array();
		}
		
		/**
		 * Adds a curve to the channel.
		 * 
		 * @param	curve
		 * @return
		 */
		public function addCurve( curve:AbstractCurve ):AbstractCurve
		{
			this.curves.push( curve );
			return curve;
		}
		
		/**
		 * 
		 * @param	type
		 * @return
		 */
		public function findCurveByType( type:String ):AbstractCurve
		{
			for( var i:int = 0; i < curves.length; i++ )
			{
				if( curves[i].type == type )
					return curves[i];
			}
			return null;
		}
		
		/**
		 * Removes a curve from the channel.
		 * 
		 * @param	curve
		 * @return
		 */
		public function removeCurve( curve:AbstractCurve ):AbstractCurve
		{
			var tmp:Array = new Array();
			var removed:AbstractCurve;
			for( var i:int = 0; i < curves.length; i++ )
			{
				if( curves[i] === curve )
					removed = curves[i];
				else
					tmp.push(curves[i]);
			}
			curves = tmp;
			return removed;
		}
		
		/**
		 * bake matrix curves from rotation curves.
		 * 
		 * @return
		 */
		public function bakeMatrices():void
		{
			var cX:AbstractCurve = findCurveByType(RotationCurve.ROTATION_X);
			var cY:AbstractCurve = findCurveByType(RotationCurve.ROTATION_Y);
			var cZ:AbstractCurve = findCurveByType(RotationCurve.ROTATION_Z);
			
			if( cX || cY || cZ )
			{
				var maxkeyX:uint = cX ? cX.keys.length : 0;
				var maxkeyY:uint = cY ? cY.keys.length : 0;
				var maxkeyZ:uint = cZ ? cZ.keys.length : 0;
				var maxkey:uint = Math.max(maxkeyX, maxkeyY);
				
				maxkey = Math.max(maxkey, maxkeyZ);
				
				var keys:Array = new Array(maxkey);
				var matrices:Array = new Array(maxkey);
				
				var mat:Object = new Object();
				mat.n11 = new Array();
				mat.n12 = new Array();
				mat.n13 = new Array();
				mat.n21 = new Array();
				mat.n22 = new Array();
				mat.n23 = new Array();
				mat.n31 = new Array();
				mat.n32 = new Array();
				mat.n33 = new Array();
				
				for( var i:int = 0; i < maxkey; i++ )
				{
					var key:Number = (cX && cX.keys[i] is Number) ? cX.keys[i] : Number.NaN;
					
					key = (isNaN(key) && cY && cY.keys[i] is Number) ? cY.keys[i] : Number.NaN;
					key = (isNaN(key) && cZ && cZ.keys[i] is Number) ? cZ.keys[i] : Number.NaN;
					
					if( isNaN(key) )
						throw new Error( "Could not find a valid key." );
						
					keys[i] = key;
					matrices[i] = createMatrixFromRotations(i);
					
					mat.n11.push(matrices[i].n11);
					mat.n12.push(matrices[i].n12);
					mat.n13.push(matrices[i].n13);
					mat.n21.push(matrices[i].n21);
					mat.n22.push(matrices[i].n22);
					mat.n23.push(matrices[i].n23);
					mat.n31.push(matrices[i].n31);
					mat.n32.push(matrices[i].n32);
					mat.n33.push(matrices[i].n33);
				}
				
				if( cX )
					removeCurve( cX );
				if( cY )
					removeCurve( cY );
				if( cZ )
					removeCurve( cZ );
				
				addCurve( new MatrixCurve(this.target.transform, MatrixCurve.MATRIX_N11, keys, mat.n11) );
				addCurve( new MatrixCurve(this.target.transform, MatrixCurve.MATRIX_N12, keys, mat.n12) );
				addCurve( new MatrixCurve(this.target.transform, MatrixCurve.MATRIX_N13, keys, mat.n13) );
				addCurve( new MatrixCurve(this.target.transform, MatrixCurve.MATRIX_N21, keys, mat.n21) );
				addCurve( new MatrixCurve(this.target.transform, MatrixCurve.MATRIX_N22, keys, mat.n22) );
				addCurve( new MatrixCurve(this.target.transform, MatrixCurve.MATRIX_N23, keys, mat.n23) );
				addCurve( new MatrixCurve(this.target.transform, MatrixCurve.MATRIX_N31, keys, mat.n31) );
				addCurve( new MatrixCurve(this.target.transform, MatrixCurve.MATRIX_N32, keys, mat.n32) );
				addCurve( new MatrixCurve(this.target.transform, MatrixCurve.MATRIX_N33, keys, mat.n33) );
			}
		}
		
		/**
		 * Updates the channel.
		 * 
		 * @param	dt
		 * @return
		 */
		public function update( dt:Number ):void
		{
			var curve:AbstractCurve;
			var curves:Array = this.curves;
			var i:int = curves.length;
			
			while( curve = curves[--i] )
				curve.update(dt);
		}
		
		/**
		 * 
		 * @param	key
		 * @return
		 */
		private function createMatrixFromRotations( key:uint ):Matrix3D
		{
			var rot:Matrix3D = Matrix3D.IDENTITY;
			
			for( var i:int = 0; i < curves.length; i++ )
			{
				var curve:AbstractCurve = curves[i];
				var value:Number;
				
				if( key >= curve.keys.length || key >= curve.values.length )
					continue;
					
				switch( curve.type )
				{
					case RotationCurve.ROTATION_X:
						value = curve.values[ key ] * (Math.PI/180);
						rot = Matrix3D.multiply( rot, Matrix3D.rotationMatrix(1,0,0,value) );
						break;
					case RotationCurve.ROTATION_Y:
						value = curve.values[ key ] * (Math.PI/180);
						rot = Matrix3D.multiply( rot, Matrix3D.rotationMatrix(0,1,0,value) );
						break;
					case RotationCurve.ROTATION_Z:
						value = curve.values[ key ] * (Math.PI/180);
						rot = Matrix3D.multiply( rot, Matrix3D.rotationMatrix(0,0,1,value) );
						break;
					default:
						break;
				}
			}	
			
			return rot;
		}
	}	
}
