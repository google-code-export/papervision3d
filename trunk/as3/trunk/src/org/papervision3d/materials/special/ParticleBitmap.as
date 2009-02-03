package org.papervision3d.materials.special
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * Used to store the bitmap for a particle material. It also stores scale and offsets for moving the registration point of the bitmap. 
	 * 
	 * @author Seb Lee-Delisle
  	 */
  	 
	public class ParticleBitmap
	{
		public var offsetX : Number ; 
		public var offsetY : Number ; 
		public var scaleX : Number ; 
		public var scaleY : Number ; 
		public var bitmap : BitmapData; 
		public var width : int; 
		public var height : int; 
		
		public function ParticleBitmap(source : * = null, scale : Number = 1, forceMipMap : Boolean = false, posX : Number =0, posY:Number =0)
		{
			offsetX = 0; 
			offsetY = 0; 
			scaleX = scale; 
			scaleY = scale; 
			if(source is BitmapData)
			{
				bitmap = source as BitmapData;
				width = bitmap.width; 
				height = bitmap.height; 
			} 
			else if (source is DisplayObject)
			{
				create(source as DisplayObject, scale, forceMipMap, posX, posY); 
			}
		}
		
		public function create(clip : DisplayObject, scale : Number = 1, forceMipMap : Boolean = false, posX : Number = 0, posY : Number = 0 ) : BitmapData
		{
			var bounds : Rectangle = clip.getBounds(clip); 
			
			// move the bounds rectangle to where we want it (mainly for actual size particles)
			var osx : Number = posX%1; 
			var osy : Number = posY%1; 
			bounds.x -=osx; 
			bounds.y -=osy;
			
			//expand the bounds rectangle by the scale amount and snap them to pixels
			
			bounds.left = Math.floor(bounds.left*scale); 
			bounds.right = Math.ceil(bounds.right*scale); 
			bounds.top = Math.floor(bounds.top*scale); 
			bounds.bottom = Math.ceil(bounds.bottom*scale);
			
			width = bounds.width;
			height = bounds.height; 
			
			// if we want to force mip-mapping then find the nearest mipmappable size
			if(forceMipMap)
			{
				// find the closest mipmappable size. 
				width = getNearestMipMapSize(width);
				height = getNearestMipMapSize(height);
				scaleX = (bounds.width)/width; 
				scaleY = (bounds.height)/height; 	
			
			}	
			else 
			{
				scaleX = 1/scale; 
				scaleY = 1/scale; 
			}
					
			offsetX =(bounds.left/scale)+osx;
			offsetY = (bounds.top/scale)+osy; 

			var m : Matrix = new Matrix(); 
			
			m.translate(-offsetX, -offsetY); 
			m.scale(1/scaleX, 1/scaleY);
			
			width = (width==0) ? 1 : width; 
			height = (height==0) ? 1 : height; 
			
			if((!bitmap)||(bitmap.width<width)||(bitmap.height<height))
			{
				bitmap = new BitmapData(width, height, true, 0x00000000); 
				
			}
			else 
			{
				bitmap.fillRect(bitmap.rect, 0x00000000); 
			}
			bitmap.draw(clip, m,null, null, null, true); 
			
			return bitmap ; 
		}
		
		
		
		
	
		/** 
		 * Finds the nearest MIPMAP-able size to the value you pass in. 
		 * 
		 * Kudos to Jack Lang for writing this optimised function. 
		 * 
		 * 
		 * */
		protected function getNearestMipMapSize ( val : Number ) : uint
		{
		    
		    var r : uint = Math.round ( val ) ;
		    
		    var i : uint = 0 ;
		    
		    var ret : uint ;
		    
		    var done : Boolean = false ;
		    
		    if ( r == 0 || r == 1 )
		    {
		        done = true ;
		        
		        ret = r ;
		    }
		    
		    while ( !done )
		    {
		        if ( r == 2 )
		        {
		            done = true ;
		            // round down
		            ret = Math.pow ( 2, i + 1 ) ;
		        }
		        else if ( r == 3 )
		        {
		            done = true ;
		            // round up
		            ret = Math.pow ( 2, i + 2 ) ;
		        }
		        else
		        {
		            i++ ;
		            
		            r = r >> 1 ;
		            
		            if ( i >= 10 )
		            {
		                // at max, capping
		                ret = 2048 ;
		                done = true ;
		            }
		        }
		    }
		    
		    return ret ;
		
		}
	}

}