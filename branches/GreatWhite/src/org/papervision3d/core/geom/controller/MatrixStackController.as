package org.papervision3d.core.geom.controller
{
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.objects.DisplayObject3D;
	
	public class MatrixStackController extends AbstractController
	{
		/**
		 * 
		 */ 
		public function get baked():Boolean
		{
			if(_stack.length != 1)
				return false;
			return (_types[0] == "matrix");
		}
		
		/**
		 * Constructor.
		 * 
		 * @param	 target
		 */ 
		public function MatrixStackController(target:DisplayObject3D)
		{
			super(target);
			
			_stack = new Array();
			_types = new Array();
			_ids = new Array();
			_matrix = Matrix3D.IDENTITY;
		}
		
		/**
		 * Applies the controller to the target.
		 */ 
		public override function apply():void
		{
			setIdentity();
			for(var i:int = 0; i < _stack.length; i++)
				_matrix = Matrix3D.multiply(_matrix, _stack[i]);
			this.target.transform.copy(_matrix);
		}
		
		/**
		 * Adds a matrix
		 * 
		 * @param	matrix
		 * @param 	type
		 * @param 	id
		 * 
		 * @return Index
		 */ 
		public function addMatrix(matrix:Matrix3D, type:String, id:String = null):uint
		{
			id = id || "id_" + _stack.length;
			
			_stack.push(matrix);
			_types.push(type);
			_ids.push(id);
			
			return (_stack.length - 1);
		}
		
		/**
		 * Gets a matrix type by index.
		 * 
		 * @param	index
		 * 
		 * @return 	The found matrix or null on failure.
		 */ 
		public function getMatrixAt(index:uint):Matrix3D
		{
			if(index < _stack.length)
				return _stack[index];
			else
				return null;	
		}
		
		/**
		 * Gets a matrix type by id.
		 * 
		 * @param	id
		 * 
		 * @return 	The found matrix or null on failure.
		 */ 
		public function getMatrixById(id:String):Matrix3D
		{
			for(var i:int = 0; i < _ids.length; i++)
			{
				if(_ids[i] == id)
					return _stack[i];
			}
			return null;
		}
		
		/**
		 * Gets the type of matrix by id.
		 * 
		 * @param	id
		 * 
		 * @return	The found type or null on failure.
		 */ 
		public function getMatrixTypeById(id:String):String
		{
			for(var i:int = 0; i < _ids.length; i++)
			{
				if(_ids[i] == id)
					return _types[i];
			}
			return null;
		}
		
		/**
		 * Sets a matrix in the stack by id.
		 * 
		 * @param	id	The matrix id.
		 * @param	matrix	 The new matrix.
		 * 
		 * @return	Boolean indicating success.
		 */
		public function setMatrixById(id:String, matrix:Matrix3D):Boolean
		{
			var m:Matrix3D = getMatrixById(id);
			if(m)
			{
				m.copy(matrix);
				return true;
			}
			return false;
		}
		
		/**
		 * Sets a matrix in the stack by id.
		 * 
		 * @param	id	The matrix id.
		 * @param	values	Array of values.
		 * 
		 * @return	Boolean indicating success.
		 */ 
		public function setMatrixValuesById(id:String, values:Array):Boolean
		{
			var type:String = getMatrixTypeById(id);
			if(!type)
				return false;
			var matrix:Matrix3D = getMatrixById(id);
			if(!matrix)
				return false;
				
			switch(type)
			{
				case "matrix":
					if(values.length < 12)
						return false;
					matrix = new Matrix3D(values);
					break;
				case "rotate":
					if(values.length != 4)
						return false;
					matrix = Matrix3D.rotationMatrix(values[0], values[1], values[2], values[3] * (Math.PI/180));
					break;
				case "scale":
					if(values.length != 3)
						return false;
					matrix = Matrix3D.scaleMatrix(values[0], values[1], values[2]);
					break;
				case "translate":
					if(values.length != 3)
						return false;
					matrix = Matrix3D.translationMatrix(values[0], values[1], values[2]);
					break;
				default:
					return false;
			}
			return true;
		}
		
		/**
		 * 
		 */ 
		private function setIdentity():void
		{
			_matrix.n11 = _matrix.n22 = _matrix.n33 = _matrix.n44 = 1;
			_matrix.n12 = _matrix.n13 = _matrix.n14 =
			_matrix.n21 = _matrix.n23 = _matrix.n24 =
			_matrix.n31 = _matrix.n32 = _matrix.n34 = 
			_matrix.n41 = _matrix.n42 = _matrix.n43 = 0;
		}
		
		private var _stack:Array;
		private var _types:Array;
		private var _ids:Array;		
		private var _matrix:Matrix3D;
	}
}