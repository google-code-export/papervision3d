package org.papervision3d.core.render.shader
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.papervision3d.materials.shaders.IShader;
	import org.papervision3d.materials.shaders.ShadedMaterial;
	import org.papervision3d.materials.shaders.Shader;

	public class ShaderManager extends EventDispatcher
	{
		
		private static var instance:ShaderManager = new ShaderManager();
		
		public var shadedMaterials:Array;
		public var shaderMaterialLayers:Dictionary;
		public var shadedBitmaps:Dictionary;
		public var shaderLayers:Dictionary;
		public var shaders:Array;
		
		public function ShaderManager()
		{
			if(instance){
				throw new Error("ShaderManager is a singleton");
			}
			init();
		}
		
		private function init():void
		{
			shadedMaterials = new Array();
			shaders = new Array();
			shaderMaterialLayers = new Dictionary(false);
			shadedBitmaps = new Dictionary(false);
			shaderLayers = new Dictionary(false);
		}
		
		public function registerShader(shader:IShader):void
		{
			shaders.push(shader);
		}
		
		public function registerShadedMaterial(shadedMaterial:ShadedMaterial):void
		{
			shadedMaterials.push(shadedMaterial);
			createLayerForShadedMaterial(shadedMaterial);
			createBMPForShadedMaterial(shadedMaterial);
			
			//TODO  : remove previous shader langer, or add on top.
			createLayerForShader(shadedMaterial.shader, shadedMaterial);
			
			//TODO : Think about remove here, Shader composites.
			registerShader(shadedMaterial.shader);
		}
		
		public function unregisterShaderMaterial(shaderMaterial:ShadedMaterial):void
		{
			shadedMaterials.splice(instance.shadedMaterials.indexOf(shaderMaterial,0));
			//TODO : Add removes here.
		}
		
		public function createLayerForShadedMaterial(shadedMaterial:ShadedMaterial):void
		{
			//Create a new layer;
			var sprite:Sprite = new Sprite();
			shaderMaterialLayers[shadedMaterial] = sprite;
		
			//Draw the original bmp to the first layer in there.
			var firstLayer:Sprite = new Sprite();
			firstLayer.blendMode = BlendMode.MULTIPLY;
			var g:Graphics = firstLayer.graphics;
			
			var bmp:BitmapData = shadedMaterial.material.bitmap.clone();
			g.beginBitmapFill(bmp);
			g.drawRect(0,0,bmp.width, bmp.height);
			g.endFill();
			
			//Add to the displaylist for that layer.
			sprite.addChild(firstLayer);
		}
		
		public function createBMPForShadedMaterial(shadedMaterial:ShadedMaterial):void
		{
			shadedBitmaps[shadedMaterial] = shadedMaterial.material.bitmap.clone();
			shadedMaterial.material.bitmap = shadedBitmaps[shadedMaterial];
		}
		
		public function createLayerForShader(shader:IShader, shadedMaterial:ShadedMaterial):void
		{
			var filters:Array = shader.getFilters();
			var sprite:Sprite = new Sprite();	
			sprite.filters = filters;
			shader.setLayer(sprite);
			
			shaderLayers[shader] = sprite;
			var layerSprite:Sprite = shaderMaterialLayers[shadedMaterial] as Sprite;
			layerSprite.addChildAt(sprite,0);
		}
		
		public function clearLayers():void
		{
			var shader:Shader;
			var sprite:Sprite;
			for each(sprite in shaderLayers){
				sprite.graphics.clear();
			}
		}
		
		public function renderTextures():void
		{
			var layer:Sprite;
			var bmp:BitmapData;
			var mat:ShadedMaterial;
			for each(mat in shadedMaterials){
				bmp = shadedBitmaps[mat] as BitmapData;
				bmp.fillRect(bmp.rect,0x000000);
				layer = shaderMaterialLayers[mat] as Sprite;
				bmp.draw(layer,null,null,null,bmp.rect, false);
			}
		}
		
		public function attachShaderToMaterial(shader:IShader, material:ShadedMaterial):void
		{
			var tarSprite:Sprite = instance.shaderMaterialLayers[material];
			tarSprite.addChild(shader.getLayer());
		}
		
		public function updateBeforeRender():void
		{
			var s:IShader;
			var c:int = 0;
			for each(s in shaders){
				//s.updateBeforeRender();
			}
		}
		
		public static function getInstance():ShaderManager
		{
			if(!instance){
				instance = new ShaderManager();
			}
			return instance;
		}
		
	}
}