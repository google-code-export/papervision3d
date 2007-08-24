package org.papervision3d.materials
{
       import flash.display.Graphics;
       import flash.utils.Dictionary;

       import org.papervision3d.core.Number3D;
       import org.papervision3d.core.geom.Face3D;
       import org.papervision3d.core.geom.Vertex2D;
       import org.papervision3d.core.proto.MaterialObject3D;
       import org.papervision3d.objects.DisplayObject3D;

       /**
        *
        */
       public class ShadedColorMaterial extends MaterialObject3D
       {
               public var light:Number3D;

               /**
                *
                * @param       fillColor
                * @param       fillAlpha
                */
               public function ShadedColorMaterial(fillColor:uint, fillAlpha:Number= 1.0):void
               {
                       this.fillColor = fillColor;
                       this.fillAlpha = fillAlpha;

                       this.light = new Number3D(0.6, 0.8, 0.4);

                       _shaded = new Dictionary();
               }

               /**
                *
                * @param       instance
                * @param       face3D
                * @param       graphics
                * @param       v0
                * @param       v1
                * @param       v2
                * @return
                */
               override public function drawFace3D(instance:DisplayObject3D, face3D:Face3D, graphics:Graphics, v0:Vertex2D, v1:Vertex2D, v2:Vertex2D):int
               {
                       var color:uint = this.fillColor;

                       if( face3D.faceNormal && !_shaded[face3D] )
                       {
                               var normal:Number3D = face3D.faceNormal.clone();
                               normal.normalize();

                               var cosine:Number = Number3D.dot( light, normal );

                               cosine = ((cosine>=1.0) ? 0.0 : ((cosine<=-1.0) ? Math.PI : Math.acos(cosine)));

                               cosine /= Math.PI;
                               cosine = cosine + ((1 - cosine) / 4);

                               var a:uint = color >> 24 & 0xFF;
                               var r:uint = color >> 16 & 0xFF;
                               var g:uint = color >> 8 & 0xFF;
                               var b:uint = color & 0xFF;

                               //r = 0;
                               r = Math.round(cosine * r);
                               g = Math.round(cosine * g);
                               b = Math.round(cosine * b);

                               color = b;
                               color |= g << 8;
                               color |= r << 16;

                               _shaded[face3D] = color;
                       }

                       if( _shaded[face3D] )
                               color = _shaded[face3D];

                       var x0:Number = v0.x;
                       var y0:Number = v0.y;
                       var x1:Number = v1.x;
                       var y1:Number = v1.y;
                       var x2:Number = v2.x;
                       var y2:Number = v2.y;

                       graphics.beginFill( color, fillAlpha );
                       graphics.moveTo( x0, y0 );
                       graphics.lineTo( x1, y1 );
                       graphics.lineTo( x2, y2 );
                       graphics.lineTo( x0, y0 );
                       graphics.endFill();

                       return 1;
               }

               private var _shaded:Dictionary;
       }
}