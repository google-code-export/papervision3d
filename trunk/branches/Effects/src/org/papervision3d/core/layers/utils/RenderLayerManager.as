/**
* ...
* @author Default
* @version 0.1
*/

package org.papervision3d.core.layers.utils {
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.layers.EffectLayer;
	import org.papervision3d.core.layers.RenderLayer;
	import org.papervision3d.core.proto.SceneObject3D;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;
	
	public class RenderLayerManager extends EventDispatcher{
		
		//all the layers
		public var layers:Dictionary;
		public var effectLayers:Dictionary;
		public var defaultLayer:RenderLayer;
		public var sortMode:int = RenderLayerSortMode.Z_SORT;
		private var containerLayers:Dictionary;
		
		
		//reference to the scene
				
		public function RenderLayerManager(){

			layers = new Dictionary();
			effectLayers = new Dictionary();
			containerLayers = new Dictionary();
			
		}
		
		public function resetLayers():void{
			
			for each(var layer:RenderLayer in layers){
				layer.faceCount = 0;
				layer.screenDepth = 0;
				layer.graphics.clear();
			}
			
			for each(var elayer:RenderLayer in effectLayers){
				elayer.faceCount = 0;
				elayer.screenDepth = 0;
				elayer.graphics.clear();
			}
		}
		
		public function checkIndividualLayers(scene:SceneObject3D, viewport:Viewport3D):void{
			
			//get current list of containers in viewport
	
			var rl:RenderLayer;
			for each(var do3d:DisplayObject3D in scene.children){
				if(do3d.hasOwnRenderLayer){
					if(do3d.renderLayer == null){
						rl = new RenderLayer();
						viewport.addRenderLayer(rl);
						do3d.renderLayer = rl;
						viewport.containers[do3d] = rl;
						
					}
					
					do3d.renderLayer.filters = do3d.filters;
					
				}else{
					
					//doesn't want own renderLayer - make sure its not on the containers list
					if(viewport.containers[do3d]){
						viewport.removeRenderLayer(viewport.containers[do3d]);
						viewport.containers[do3d] = null;
						delete viewport.containers[do3d];
					}
					
				}
			}
		}
		
		public function addDefaultLayer(layer:RenderLayer):void{
			defaultLayer = layer;
			addRenderLayer(layer);
		}
		public function getDefaultLayer():RenderLayer{
			return defaultLayer;
		}
		
		public function addRenderLayer(layer:RenderLayer):void{
			if(layer is EffectLayer)
				effectLayers[layer] = layer;
			else
				layers[layer] = layer;
		}
		
		
		public function removeRenderLayer(layer:RenderLayer):void{
			if(layer is EffectLayer){
				effectLayers[layer] = null;
				delete effectLayers[layer];
			}else{
				layers[layer] = null;
				delete layers[layer];
			}
		}
		
		public function updateBeforeRender():void{
			for each(var el:EffectLayer in effectLayers){
				el.updateBeforeRender();
			}
		}
		
		public function updateAfterRender():void{
			for each(var el:EffectLayer in effectLayers){
				el.renderEffects();
			}
		}
		
		public function sortlayers(container:Sprite):void{
			
			//container holds all our layers!
			
			if(sortMode == RenderLayerSortMode.Z_SORT){
				zSort(container);
			}else if(sortMode == RenderLayerSortMode.INDEX_SORT){
				indexSort(container);
			}
			
		

			
		}
		
		private function indexSort(container:Sprite):void{
			
			var sort:Array = [];
			
			for each (var layer:RenderLayer in layers){
				layer.screenDepth /= layer.faceCount;
				
				sort.push({layer:layer, screenDepth:layer.layerIndex});
			}
			
			for each (var elayer:EffectLayer in effectLayers){
				elayer.screenDepth /= elayer.faceCount;
				
				sort.push({layer:elayer, screenDepth:elayer.layerIndex});
			}
			
			sort.sortOn("screenDepth", Array.DESCENDING | Array.NUMERIC);
			var c:int = -1;
			
			for(var i:uint=0;i<sort.length;i++){
				
				if(sort[i].layer.parent == container){
					c++;
					container.setChildIndex(sort[i].layer, c);
				}
			}
		}
		
		private function zSort(container:Sprite):void{
						
			var sort:Array = [];
			
			for each (var layer:RenderLayer in layers){
				layer.screenDepth /= layer.faceCount;
				
				sort.push({layer:layer, screenDepth:layer.screenDepth});
			}
			
			for each (var elayer:EffectLayer in effectLayers){
				elayer.screenDepth /= elayer.faceCount;
				
				sort.push({layer:elayer, screenDepth:elayer.screenDepth});
			}
			
			sort.sortOn("screenDepth", Array.DESCENDING | Array.NUMERIC);

			var c:int = -1;
			for(var i:uint=0;i<sort.length;i++){
				
					if(sort[i].layer.parent == container){
						container.setChildIndex(sort[i].layer, ++c);
					}
			
			}
			
			
		}
		
		private static var _instance:RenderLayerManager;
		public static function getInstance():RenderLayerManager{
			if(_instance == null)
				_instance = new RenderLayerManager();
			
			return _instance;
		}
		
		
	}
	
}
