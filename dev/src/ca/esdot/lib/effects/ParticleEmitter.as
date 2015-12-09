package ca.esdot.lib.effects
{	
	import com.gskinner.motion.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * Generates particles.
	 */
	public class ParticleEmitter extends Sprite
	{
		public static var PARTICLES_DEAD:String = "particlesDead";
		
		/** Maintain an internal reference to the particleManager so we don't have to make costly static calls. */
		protected var particleManager:ParticleManager;
		
		/** First node in our Particle linkedList */
		protected var particleList:Particle;
		
		/** Current number of particles in the emitter */
		protected var particleCount:int = 0;
		
		/** Emitter has been initialized by the ParticleManager and can begin generating particles. */ 
		protected var initComplete:Boolean = false;
		
		/**
		 * Tells the emitter to re-initialize each particle when they die. 
		 * When this is true an emitter will continue to generate particles indefinately.
		 */
		public var recycleParticles:Boolean = true;
		
		/**
		 * Size in pixels for each particle. Keep in mind that this will be affected by any 
		 * transforms (scaleX, scaleY) that are applied to the parent object.
		 */
		public var particleSize:int = 20;
		
		/** Variance in size +/- */
		public var particleSizeVariance:int = 10;
		
		/** Horizontal speed of the particle. */
		public var xVelocity:Number = 0;
		/** Variance in horizonatal speed +/- */
		public var xVelocityVariance:Number = 3;
		
		/** Vertical speed of the particle. */
		public var yVelocity:Number = -5;
		/** Variance in vertical speed +/- */
		public var yVelocityVariance:Number = 2;
		
		/** Determines how long a particle will exist before it dies. */
		public var lifeSpan:Number = 3;
		/** Variance in lifeSpan +/- */
		public var lifeSpanVariance:Number = 2;
		
		/** Pauses the emitter, so that no updates will occur. */
		public var paused:Boolean = false;
			
		/** Sprite class used to texture particle. */
		public var ParticleAsset:Class;
		
		/** Max number of particles allowed */
		public var maxParticles:uint = 100;
		
		/** Position particles at a specific offset */
		public var originPoint:Point;
		
		/** Affect deceleration on the y axis (vertical) */
		public var gravity:Number = 1;
		
		/** Affect deceleration on both the x/y axis (vertical) */
		public var viscosity:Number = 1;
		
		/** Set the amount of particles the emitter will generate. */
		public function set numParticles(value:int):void {
			maxParticles = value;
			if(initComplete){ updateNumParticles(); }
		}
		
		public function ParticleEmitter(ParticleAsset:Class){
			this.ParticleAsset = ParticleAsset;
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		/** Starts emitter, this should only ever be called by the ParticleManager. */
		internal function init():void {
			particleManager = ParticleManager.instance;
			//Build the internal particlePool list.
			for(var i:uint = 0; i < maxParticles; i++){
				addParticle();
			}
			initComplete = true;
		}
		
		/** Loop through all particles in the emitter and update them */
		internal function update():void {
			if(paused){ return; }
			var particle:Particle = particleList;
			var prevParticle:Particle;
			var count:uint = 0;
			while(particle != null){
				particle.x += particle.xVel;
				particle.y += particle.yVel;
				particle.yVel *= gravity;
				particle.yVel *= viscosity;
				particle.xVel *= viscosity;
				particle.decay();

				prevParticle = null;
				if(particle.lifeSpan < .01){ 
					if(recycleParticles == false){
						prevParticle = particle.prev;
						removeChild(particle);
						returnParticle(particle);
					}
					else { initParticle(particle); }
				}
				
				particle = (prevParticle == null)? particle.prev : prevParticle;
				count++;
			}
			if(particleList == null){
				dispatchEvent(new Event(ParticleEmitter.PARTICLES_DEAD));
			}
		}
		
		
		/** Do everything required to create a new particle. */
		protected function addParticle():void {
			var particle:Particle = getParticle();
			particle.setSprite(ParticleAsset);
			initParticle(particle);
			addChild(particle);
		}
		
		/** Get particle form the global particlePool, and insert into the internal linkedList. */
		protected function getParticle():Particle {
			var particle:Particle = particleManager.getParticle();
			//Handle first node.
			if(particleList == null){ particleCount++; return particleList = particle; }
			//Handle subsequent nodes:
			particleList.next = particle;
			particle.prev = particleList;
			particleList = particle;
			particleCount++;
			return particle;
		}
		
		/** Return particle to the global pool, and patch up the internal linkedList. */
		protected function returnParticle(particle:Particle):void {
			if(particle.next){
				particle.next.prev = particle.prev;
			}
			else{
				particleList = particle.prev;
			}
			if(particle.prev){
				particle.prev.next = particle.next;
			}
			particleManager.returnParticle(particle);
			particleCount--;
		}
		
		/** Set initial properties on a particle */
		protected function initParticle(particle:Particle):void {
			var size:int = particleSize + (particleSizeVariance * getRandom());
			particle.width = particle.height = size;
			particle.x = (originPoint)? originPoint.x : 0;
			particle.y = (originPoint)? originPoint.y : 0;
			particle.xVel = xVelocity + xVelocityVariance * getRandom();
			particle.yVel = yVelocity + yVelocityVariance * getRandom();
			particle.lifeSpan = lifeSpan + lifeSpanVariance * getRandom();
			particle.alpha = 1;
			particle.cacheAsBitmap = true;
		}
		
		/** Helper function which returns a random value between -1 and 1 */
		protected function getRandom():Number {
			return -1 + 2 * Math.random();
		}
		
		/** Handle changes to the number of displayed particles. */
		protected function updateNumParticles():void {
			var l:uint;
			var i:uint;
			var particle:Particle;
			
			var newParticleCount:int = maxParticles - particleCount;
			if(newParticleCount > 0){
				l = newParticleCount + particleCount;
				for(i = particleCount; i < l; i++){
					addParticle();
				}
			}
			else if(newParticleCount < 0){
				newParticleCount = particleCount + newParticleCount;
				while(particleCount > newParticleCount){
					removeChild(particleList);
					returnParticle(particleList);
				}
			}
		}
	}
}

