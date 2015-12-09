package
{
	import ca.esdot.lib.utils.DeviceUtils;
	
	public class PicShopAmazon extends PicShop
	{
		public function PicShopAmazon() {
			DeviceUtils.deviceOverride = DeviceUtils.AMAZON;
			super();
		}
	}
}