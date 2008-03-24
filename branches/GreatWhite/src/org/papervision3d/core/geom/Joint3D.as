package org.papervision3d.core.geom
{
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.core.proto.MaterialObject3D;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.objects.DisplayObject3D;

	public class Joint3D extends DisplayObject3D
	{
		/**
		 * Array of animation channels. @see org.papervision3d.core.animation.AnimationChannel3D
		 */ 
		public var channels:Array;
		
		/**
		 * Vertex weights. Used by skinning.
		 */ 
		public var vertexWeights:Array;
		
		/**
		 * Inverse bind matrix. Used by skinning.
		 */ 
		public var inverseBindMatrix:Matrix3D;
		
		/**
		 * 
		 */ 
		public function set transformsDirty(dirty:Boolean):void { _transformsDirty = dirty; }
		
		/**
		 * 
		 */ 
		public function get transformsDirty():Boolean { return _transformsDirty; }
		
		/**
		 * Constructor.
		 * 
		 * @param	name
		 */ 
		public function Joint3D(name:String=null)
		{
			super(name);

			this.channels = new Array();
			this.vertexWeights = new Array();
			
			_baked = true;
			_matrixStack = new Array();
			_matrixByID = new Object();
			_matrixByType = new Object();
			_transformsDirty = true;
		}	
		
		/**
		 * 
		 */ 
		public function addTransform(transform:Matrix3D, type:String, id:String):void
		{
			switch(type)
			{
				case "matrix":
					_baked = true;
					this.copyTransform(transform);
					_matrixByType[ type ] = this.transform;
					_matrixByID[ id ] = this.transform;
					break;
				
				case "rotate":
				case "scale":
				case "translate":
					_baked = false;
					_matrixStack.push(transform);
					_matrixByType[ type ] = transform;
					_matrixByID[ id ] = transform;
					break;
				
				default:
					throw new Error("Unknow matrix type: " + type);
			}	
			
			_transformsDirty = true;
		}
		
		/**
		 * Gets a matrix from the stack.
		 * 
		 * @param	id
		 * 
		 * @return The found matrix or null on failure.
		 */ 
		public function getTransformByID(id:String):Matrix3D
		{
			return _matrixByID[ id ];
		}
		
		/**
		 * Gets the type of matrix.
		 * 
		 * @param	id
		 * 
		 * @return The found matrix or null on failure.
		 */ 
		public function getTransformTypeByID(id:String):String
		{
			var matrix:Matrix3D = _matrixByID[ id ];
			
			for(var type:String in _matrixByType)
			{
				if(_matrixByType[type] === matrix)
					return type;
			}
			
			return null;
		}
		
		/**
		 * Project.
		 * 
		 * @param	parent
		 * @param	renderSessionData
		 */ 
		public override function project(parent:DisplayObject3D, renderSessionData:RenderSessionData):Number
		{
			//if(!_baked && _transformsDirty)
			//	bake();
				
			return super.project(parent, renderSessionData);
		}
		
		/**
		 * Updates one of the matrices in the matrix stack.
		 * 
		 * @param	transform
		 * @param	id
		 */ 
		public function updateTransformByID(transform:Matrix3D, id:String):void
		{
			var matrix:Matrix3D = _matrixByID[id];
			if(matrix)
			{
				matrix.copy(transform);
				_transformsDirty = true;	
			}
		}
		
		/**
		 * Bakes the transform from the matrixStack. @see #_matrixStack
		 */ 
		protected function bake():void
		{
			_transformsDirty = false;
			var matrix:Matrix3D = Matrix3D.IDENTITY;
			for(var i:int = 0; i < _matrixStack.length; i++)
				matrix = Matrix3D.multiply(matrix, _matrixStack[i]);		
			this.copyTransform(matrix);
		}
		
		/** */
		private var _baked:Boolean;
		
		/** */
		private var _matrixStack:Array;
		
		/** */
		private var _matrixByID:Object;
		
		/** */
		private var _matrixByType:Object;
		
		/** */
		private var _transformsDirty:Boolean;
	}
}