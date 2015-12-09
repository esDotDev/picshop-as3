package ca.esdot.picshop.views
{
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import ca.esdot.picshop.MainModel;
	import ca.esdot.picshop.commands.events.CommandEvent;
	import ca.esdot.picshop.commands.events.SettingsEvent;
	import ca.esdot.picshop.data.UnlockableFeatures;
	import ca.esdot.picshop.events.ModelEvent;
	import ca.esdot.picshop.services.SupersonicService;
	import ca.esdot.picshop.services.TapjoyService;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class UnlockFeaturesViewMediator extends Mediator
	{
		[Inject]
		public var view:UnlockFeaturesView;
		
		[Inject]
		public var mainModel:MainModel;
		
		[Inject]
		public var supersonic:SupersonicService;
		
		override public function onRegister():void {
			
			//Map UI listeners
			view.purchaseClicked.add(onPurchaseClicked);
			view.purchaseWithCoinsClicked.add(onPurchaseWithCoinsClicked);
			view.showOfferwallClicked.add(onShowOfferWallClicked);
			
			//Map Model Listeners
			addContextListener(ModelEvent.COINS_ADDED, onCoinsEarned);
			
			//Inject numCoins/cost?
			switch(view.featureType){
				
				case UnlockableFeatures.FILTERS:
					view.coinCost = 10;
					view.moneyCost = "$0.99";
					break;
				
				case UnlockableFeatures.FRAMES:
					view.coinCost = 20;
					view.moneyCost = "$1.99";
					break;
				
				case UnlockableFeatures.EXTRAS:
					view.coinCost = 30;
					view.moneyCost = "$2.99";
					break;
			}
			view.numCoins = mainModel.numCoins;
		}
		
		protected function onCoinsEarned(event:ModelEvent):void {
			view.tweenCoins(mainModel.numCoins);
		}
		
		protected function onShowOfferWallClicked():void {
			dispatch(new CommandEvent(CommandEvent.SHOW_OFFERWALL));
		}
		
		protected function onPurchaseWithCoinsClicked():void {
			if(mainModel.numCoins >= view.coinCost){
				mainModel.numCoins -= view.coinCost;
				mainModel.unlockFeature(view.featureType);
				dispatch(new SettingsEvent(SettingsEvent.SAVE));
			} else {
				onShowOfferWallClicked();
			}
		}
		
		protected function onPurchaseClicked():void {
			
			dispatch(new CommandEvent(CommandEvent.IN_APP_PURCHASE, view.featureType));
			
		}
		
	}
}