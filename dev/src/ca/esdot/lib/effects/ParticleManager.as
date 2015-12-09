package ca.esdot.lib.effects
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/** 
	 * ParticleManager is resonsible for starting emitters, updating the emitters each frame, 
	 * removing them from memory when they have died, and maintaining a global particlePool to 
	 * keep the memory footprint stable.
	 */
	
	public class ParticleManager extends Sprite
	{
		
		/**
		 * The size of the initial object pool. The pool will not be created until you add your first emitter, 
		 * or when manually call createPool();
		 */
		public static var minPoolSize:int = 1000;
		
		/**
		 * The amount by which the pool should grow when it becomes empty
		 */
		public static var poolGrowthRate:uint = 500;
			
		protected var emitterList:Dictionary = new Dictionary(false);
		protected var particlePool:Array;
		protected var count:uint;
		
		protected static var _instance:ParticleManager;
		public static function get instance():ParticleManager {
			if(!_instance){ _instance = new ParticleManager(new SingletonEnforcer()); }
			return _instance;
		}
		
		public function ParticleManager(se:SingletonEnforcer)
		{
			super();
			addEventListener(Event.ENTER_FRAME, updateEmitters);
		}
		
		/**
		 * Will immediately create the initial particle pool.
		 */
		public static function createPool():void {
			if(instance.particlePool != null){ return; }
			_instance.init(); 
		}
		
		/**
		 * Accepts an instance of a particleEmitter, creates an object pool, and starts the emitter. If a parent is supplied, 
		 * the emitter is automatically added as a child at level 0.
		 */
		public static function addEmitter(emitter:ParticleEmitter, parent:DisplayObjectContainer=null):void {
			if(parent){ parent.addChildAt(emitter, 0); }
			createPool();
			emitter.init();
			emitter.addEventListener(ParticleEmitter.PARTICLES_DEAD, instance.handleDeadEmitter, false, 0, true);
			instance.emitterList[emitter] = true;
		}
		
		/**
		 * Accepts an instance of a particleEmitter, creates an object pool, and starts the emitter. If a parent is supplied, 
		 * the emitter is automatically added as a child at level 0.
		 */
		public static function removeEmitter(emitter:ParticleEmitter):void {
			if(emitter.parent){ emitter.parent.removeChild(emitter); }
			emitter.removeEventListener(ParticleEmitter.PARTICLES_DEAD, instance.handleDeadEmitter);
			delete instance.emitterList[emitter];
		}
		
		/**
		 * Returns a particle from the particlePool. If the pool is empty, new particles will be created 
		 * according to the particleGrowthRate setting.
		 */
		public function getParticle():Particle {
			if(count > 0){
				return particlePool[--count];
			}
			//If we've reached zero, refill pool:
			for(var i:uint = 0; i < poolGrowthRate; i++){
				particlePool.unshift(new Particle());
			}
			//trace(">> Increase object pool by: ", poolGrowthRate);
			count = poolGrowthRate;
			return getParticle();
		}
		
		/**
		 * Add a particle back into the pool.
		 */
		public function returnParticle(particle:Particle):void {
			particle.next = particle.prev = null;
			particlePool[count++] = particle;
		}
		
		protected function init():void {
			particlePool = [];
			for(var i:uint = 0; i < minPoolSize; i++){
				particlePool[i] = new Particle();
			}
			count = minPoolSize-1;
		}
		
		protected function handleDeadEmitter(event:Event):void {
			var emitter:ParticleEmitter = event.target as ParticleEmitter;
			if(emitter.parent){ emitter.parent.removeChild(emitter); }
			emitter.removeEventListener(ParticleEmitter.PARTICLES_DEAD, instance.handleDeadEmitter);
			emitterList[emitter] = null;
			delete emitterList[emitter];
		}
		
		protected function updateEmitters(event:Event):void {
			for (var emitter:Object in emitterList){
				(emitter as ParticleEmitter).update();
			}
		}
	}
}

class SingletonEnforcer{};