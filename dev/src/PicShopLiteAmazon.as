package
{
	import ca.esdot.lib.utils.DeviceUtils;

	public class PicShopLiteAmazon extends PicShop
	{
		public function PicShopLiteAmazon() {
			PicShop.FULL_VERSION = false;
			DeviceUtils.deviceOverride = DeviceUtils.AMAZON;
			super();
		}
	}
}