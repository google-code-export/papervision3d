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
	import org.ascollada.ASCollada;
	import org.ascollada.core.DaeChannel;
	import org.ascollada.utils.Logger;
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.Papervision3D;
	
	/**
	 * @author	Tim Knip 
	 */
	public class DaeTransform 
	{
		/** type - required */
		public var type:String;
		
		/** sid - optional */
		public var sid:String;
		
		/** */
		public var values:Array;
		
		/** matrix created from type and values */
		public var matrix:Array;
		
		/**
		 * 
		 * @param	type
		 * @param	values
		 * @return
		 */	
		public function DaeTransform( type:String, sid:String, values:Array, yUp:Boolean = false ):void
		{
			this.type = type;
			this.sid = sid;
			this.values = values;
			
			_yUp = yUp;
			
			if( !validateValues() )
			{
				Logger.trace( "[ERROR] invalid values for this transform!" );
				throw new Error( "[ERROR] invalid values for this transform!" );
			}
			
			this.matrix = buildMatrix();
		}
		
		/**
		 * 
		 * @param	channel	the animation channel. @see org.ascollada.core.DaeChannel
		 * 
		 * @return
		 */
		public function buildAnimatedMatrices( channel:DaeChannel ):Array
		{
			var output:Array = channel.output;
			var matrices:Array = new Array();
			var i:int;
			
			switch( this.type )
			{
				case ASCollada.DAE_ROTATE_ELEMENT:
					if(channel.syntax.member == "ANGLE")
					{
						for( i = 0; i < output.length; i++ )
							matrices.push( rotationMatrix(values[0], values[1], values[2], output[i]) );
					}
					else
						Logger.trace( " => => " + this.type + " " + channel.syntax );
					break;
				case ASCollada.DAE_TRANSLATE_ELEMENT:
					if( channel.syntax.isFullAccess )
					{
						for( i = 0; i < output.length; i++ )
							matrices.push( translationMatrix(output[i][0], output[i][1], output[i][2]) );
					}
					else if( channel.syntax.member == "X" )
					{
						for( i = 0; i < output.length; i++ )
							matrices.push( translationMatrix(output[i], 0, 0) );						
					}
					else if( channel.syntax.member == "Y" )
					{
						for( i = 0; i < output.length; i++ )
							matrices.push( translationMatrix(0, output[i], 0) );						
					}
					else if( channel.syntax.member == "Z" )
					{
						for( i = 0; i < output.length; i++ )
							matrices.push( translationMatrix(0, 0, output[i]) );						
					}
					else
					{
						Logger.trace( " => => " + this.type + " " + channel.syntax );
					}
					break;
				case ASCollada.DAE_SCALE_ELEMENT:
					Logger.trace( " => buildAnimatedMatrices " + this.type );
					break;
				case ASCollada.DAE_MATRIX_ELEMENT:
					if( channel.syntax.isFullAccess )
					{
						for( i = 0; i < channel.output.length; i++ )
							matrices.push( bakedMatrix(channel.output[i]) );
					}
					break;
				default:
					Logger.trace( " => unknown type " + this.type );
					break;
			}
			
			return matrices;
		}
		
		/**
		 * 
		 * @return
		 */
		public function buildMatrix():Array
		{
			var matrix:Array = null;
			
			switch( this.type )
			{
				case ASCollada.DAE_ROTATE_ELEMENT:
					matrix = rotationMatrix(values[0], values[1], values[2], values[3]);
					break;
				case ASCollada.DAE_TRANSLATE_ELEMENT:
					matrix = translationMatrix(values[0], values[1], values[2]);
					break;
				case ASCollada.DAE_SCALE_ELEMENT:
					matrix = scaleMatrix(values[0], values[1], values[2]);
					break;
				case ASCollada.DAE_MATRIX_ELEMENT:
					matrix = bakedMatrix(values);
					break;
				default:
					Logger.trace( "[ERROR] don't know how to create a matrix with type=" + this.type );
					throw new Error( "don't know how to create a matrix with type=" + this.type );
					break;
			}
			
			return matrix;
		}
		
		/**
		 * 
		 * @return
		 */
		public function validateValues():Boolean
		{
			var valid:Boolean = false;
			
			if( !this.values || !this.values.length )
				return false;
				
			switch( this.type )
			{
				case ASCollada.DAE_ROTATE_ELEMENT:
					valid = (this.values.length == 4);
					break;
				case ASCollada.DAE_TRANSLATE_ELEMENT:
					valid = (this.values.length == 3);
					break;
				case ASCollada.DAE_SCALE_ELEMENT:
					valid = (this.values.length == 3);
					break;
				case ASCollada.DAE_MATRIX_ELEMENT:
					valid = (this.values.length == 16);
					break;
				default:
					break;
			}
			
			return valid;
		}
		
		/**
		 * 
		 * @param	values
		 * @return
		 */
		private function bakedMatrix( values:Array ):Array
		{
			var result:Array;
			if( !_yUp )
			{
				/*
				var fix:Array = [
					1, 0, 0, 0,
					0, 0, 1, 0,
					0, 1, 0, 0
				];
				result = multiply(fix, values);
				
				result = new Array(12);
				result[0] = values[0];
				result[1] = values[1];
				result[2] = values[2];
				result[3] = values[3];
				result[4] = values[4];
				result[5] = values[5];
				result[6] = values[6];
				result[7] = values[11];
				result[8] = values[8];
				result[9] = values[9];
				result[10] = values[10];
				result[11] = values[7];
				*/
				result = values;
				
				
			}
			else
				result = values;
			return result;
		}
		
		public function testDecompose():void
		{
			var m:Matrix3D = Matrix3D.rotationMatrix(0, 1, 0, Math.PI/4);
			
			var matrix:Array = [
				m.n11, m.n12, m.n13, m.n14,
				m.n21, m.n22, m.n23, m.n24,
				m.n31, m.n32, m.n33, m.n34
			];
			
			decomposeMatrix(matrix);
			
			m = Matrix3D.multiply(Matrix3D.scaleMatrix(10, 10, 10), m);
			
			matrix = [
				m.n11, m.n12, m.n13, m.n14,
				m.n21, m.n22, m.n23, m.n24,
				m.n31, m.n32, m.n33, m.n34
			];
			
			decomposeMatrix(matrix);
		}
		
		private function decomposeMatrix( values:Array ):Array
		{
			var tx:Number = values[3];
			var ty:Number = values[7];
			var tz:Number = values[11];
			
			var x:Array = [values[0], values[1], values[2]];
			var y:Array = [values[4], values[5], values[6]];
			var z:Array = [values[8], values[9], values[10]];
			
			var nx:Array = normalize(x);
			var ny:Array = normalize(y);
			var nz:Array = normalize(z);
			
			var nm:Array = [
				nx[0], nx[1], nx[2], 0,
				ny[0], ny[1], ny[2], 0,
				nz[0], nz[1], nz[2], 0
			];
			
			var d:Number = det(nm);
			
			var sx:Number = Math.sqrt( x[0]*x[0] + x[1]*x[1] + x[2]*x[2] );
			var sy:Number = Math.sqrt( y[0]*y[0] + y[1]*y[1] + y[2]*y[2] );
			var sz:Number = Math.sqrt( z[0]*z[0] + z[1]*z[1] + z[2]*z[2] );
			
			sx = d < 0 ? -sx : sx;
			
			var rotx:Number = Math.atan2(nm[9], nm[10]);
			var roty:Number = Math.asin(nm[2]);
			var rotz:Number = Math.atan2(nm[1], nm[0]);
						
			// Remove the rot.x rotation from M, so that the remaining
			// rotation, N, is only around two axes, and gimbal lock
			// cannot occur.
			var n:Array = nm;
			var rx:Array = rotateX( -rotx );
			n = multiply( rx, nm );
			
			// Extract the other two angles, rot.y and rot.z, from N.
			var cy:Number = Math.sqrt( n[0] * n[0] + n[1] * n[1]);
			roty = Math.atan2( -n[2], cy );
			rotz = Math.atan2( -n[4], n[0] );
		
			// Fix angles
			if( Math.abs(rotx) == Math.PI )
			{
				if( roty > 0 )
					roty -= Math.PI;
				else
					roty += Math.PI;

				rotx = 0;
				rotz += Math.PI;
			}
			
			Papervision3D.log( "det: " + d );
			Papervision3D.log( "tx: " + tx );
			Papervision3D.log( "ty: " + ty );
			Papervision3D.log( "tz: " + tz );
			Papervision3D.log( "scale x: " + sx );
			Papervision3D.log( "scale y: " + sy );
			Papervision3D.log( "scale z: " + sz );
			Papervision3D.log( "rotation x: " + (rotx*toDEGREES) + " " + rotx );
			Papervision3D.log( "rotation y: " + (roty*toDEGREES) + " " + roty );
			Papervision3D.log( "rotation z: " + (rotz*toDEGREES) + " " + rotz );
			
			var mx:Array = rotationMatrix(1, 0, 0, rotx);
			var my:Array = rotationMatrix(0, 1, 0, roty);
			var mz:Array = rotationMatrix(0, 0, 1, rotz);
			
			var matrix:Array = multiply(mx, my);
			matrix = multiply(matrix, mz);
			matrix[3] = tx;
			matrix[7] = ty;
			matrix[11] = tz;
			
			var scaleM:Array = scaleMatrix(sx, sy, sz);
			matrix = multiply(matrix, scaleM);
			return matrix;
		}
		
		/**
		 * 
		 * @param	rad
		 * @return
		 */
		private function rotateX( rad:Number ):Array
		{
			var m:Array = [
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0
			];
			var c :Number   = Math.cos( rad );
			var s :Number   = Math.sin( rad );

			m[5] = c;
			m[6] = -s;
			m[9] = s;
			m[10] = c;

			return m;
		}
		
		private function normalize( v:Array ):Array
		{
			var ret:Array = [v[0], v[1], v[2]];
			
			var mod:Number = Math.sqrt( v[0]*v[0] + v[1]*v[1] + v[2]*v[2] );
			
			if( mod != 0 && mod != 1)
			{
				ret[0] = v[0] / mod;
				ret[1] = v[1] / mod;
				ret[2] = v[2] / mod;
			}
		
			return ret;
		}
		
		private function det( v:Array ):Number
		{
			/*
			0:11 1:12  2:13  3:14
			4:21 5:22  6:23  7:24
			8:31 9:32 10:33 11:34
			*/
			//return	(this.n11 * this.n22 - this.n21 * this.n12) * this.n33 - (this.n11 * this.n32 - this.n31 * this.n12) * this.n23 +
			//	(this.n21 * this.n32 - this.n31 * this.n22) * this.n13;
				
			return	(v[0] * v[5] - v[4] * v[1]) * v[10] - (v[0] * v[9] - v[8] * v[1]) * v[6] +
				(v[4] * v[9] - v[8] * v[5]) * v[2];
		}
		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	z
		 * @param	rad
		 * @return
		 */
		private function rotationMatrix( x:Number, y:Number, z:Number, deg:Number ):Array
		{
			var m:Array = [
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0
			];
			
			if( !_yUp )
			{
				var tmp:Number = y;
				y = z;
				z = tmp;
			}
			
			var rad:Number = deg * (Math.PI/180);
			var nCos:Number	= Math.cos( -rad );
			var nSin:Number	= Math.sin( -rad );
			var scos:Number	= 1 - nCos;

			var sxy	:Number = x * y * scos;
			var syz	:Number = y * z * scos;
			var sxz	:Number = x * z * scos;
			var sz	:Number = nSin * z;
			var sy	:Number = nSin * y;
			var sx	:Number = nSin * x;

			m[0] =  nCos + x * x * scos;
			m[1] = -sz   + sxy;
			m[2] =  sy   + sxz;

			m[4] =  sz   + sxy;
			m[5] =  nCos + y * y * scos;
			m[6] = -sx   + syz;

			m[8] = -sy   + sxz;
			m[9] =  sx   + syz;
			m[10] =  nCos + z * z * scos;

			return m;			
		}

		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		private function scaleMatrix( x:Number, y:Number, z:Number ):Array
		{
			var m:Array = [
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0
			];
			
			m[0]  = x;
			m[5]  = _yUp ? y : z;
			m[10] = _yUp ? z : y;
			
			return m;
		}
		
		/**
		 * 
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return
		 */
		private function translationMatrix( x:Number, y:Number, z:Number ):Array
		{
			var m:Array = [
				1, 0, 0, 0,
				0, 1, 0, 0,
				0, 0, 1, 0
			];
			
			m[3]  = _yUp ? -x : x;
			m[7]  = _yUp ?  y : z;
			m[11] = _yUp ?  z : y;
			
			return m;
		}
		
		/**
		 * Multiply two matrices.
		 * 
		 * @param	a
		 * @param	b
		 * @return
		 */
		private function multiply( a:Array, b:Array ):Array
		{
			var a11:Number = a[0]; 	var b11:Number = b[0];
			var a12:Number = a[1]; 	var b12:Number = b[1];
			var a13:Number = a[2]; 	var b13:Number = b[2];
			var a14:Number = a[3]; 	var b14:Number = b[3];
			var a21:Number = a[4]; 	var b21:Number = b[4];
			var a22:Number = a[5]; 	var b22:Number = b[5];
			var a23:Number = a[6]; 	var b23:Number = b[6];
			var a24:Number = a[7]; 	var b24:Number = b[7];
			var a31:Number = a[8]; 	var b31:Number = b[8];
			var a32:Number = a[9]; 	var b32:Number = b[9];
			var a33:Number = a[10]; var b33:Number = b[10];
			var a34:Number = a[11]; var b34:Number = b[11];

			var result:Array = new Array(12);
			result[0] = a11 * b11 + a12 * b21 + a13 * b31;
			result[1] = a11 * b12 + a12 * b22 + a13 * b32;
			result[2] = a11 * b13 + a12 * b23 + a13 * b33;
			result[3] = a11 * b14 + a12 * b24 + a13 * b34 + a14;
			result[4] = a21 * b11 + a22 * b21 + a23 * b31;
			result[5] = a21 * b12 + a22 * b22 + a23 * b32;
			result[6] = a21 * b13 + a22 * b23 + a23 * b33;
			result[7] = a21 * b14 + a22 * b24 + a23 * b34 + a24;
			result[8] = a31 * b11 + a32 * b21 + a33 * b31;
			result[9] = a31 * b12 + a32 * b22 + a33 * b32;
			result[10] = a31 * b13 + a32 * b23 + a33 * b33;
			result[11] = a31 * b14 + a32 * b24 + a33 * b34 + a34;
			return result;
		}
		
		private var _yUp:Boolean;
		
		static private var toDEGREES :Number = 180/Math.PI;
		static private var toRADIANS :Number = Math.PI/180;
	}
}
