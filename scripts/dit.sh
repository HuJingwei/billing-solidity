solgraph ../contracts/charges/Charge.sol > Charge.dot
dot -Tpng ../contracts/charges/Charge.dot > Charge.png
solgraph ../contracts/charges/FreeCharge.sol > FreeCharge.dot
dot -Tpng ../contracts/charges/FreeCharge.dot > FreeCharge.png
solgraph ../contracts/charges/IntervalCharge.sol > IntervalCharge.dot
dot -Tpng ../contracts/charges/IntervalCharge.dot > IntervalCharge.png
solgraph ../contracts/charges/TimesCharge.sol > TimesCharge.dot
dot -Tpng ../contracts/charges/TimesCharge.dot > TimesCharge.png
solgraph ../contracts/lib/ERC20.sol > ERC20.dot
dot -Tpng ../contracts/lib/ERC20.dot > ERC20.png
solgraph ../contracts/lib/ERC20Basic.sol > ERC20Basic.dot
dot -Tpng ../contracts/lib/ERC20Basic.dot > ERC20Basic.png
solgraph ../contracts/lib/Math.sol > Math.dot
dot -Tpng ../contracts/lib/Math.dot > Math.png
solgraph ../contracts/lib/Ownable.sol > Ownable.dot
dot -Tpng ../contracts/lib/Ownable.dot > Ownable.png
solgraph ../contracts/lib/SafeMath.sol > SafeMath.dot
dot -Tpng ../contracts/lib/SafeMath.dot > SafeMath.png
solgraph ../contracts/lib/Util.sol > Util.dot
dot -Tpng ../contracts/lib/Util.dot > Util.png
solgraph ../contracts/billing/BillingBasic.sol > BillingBasic.dot
dot -Tpng ../contracts/billing/BillingBasic.dot > BillingBasic.png
solgraph ../contracts/billing/DbotBilling.sol > DbotBilling.dot
dot -Tpng ../contracts/billing/DbotBilling.dot > DbotBilling.png

