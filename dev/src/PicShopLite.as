package
{
	public class PicShopLite extends PicShop
	{
		public function PicShopLite() {
			PicShop.FULL_VERSION = false;
			super();
		}
	}
}