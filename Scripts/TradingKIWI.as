
#include "TradingCommon"

TradeItem@ addTradeItem(CBlob@ this, const string &in name, const string &in iconName, const string &in configFilename, const string &in description, const bool instantShipping, Vec2f iconSize = Vec2f(1, 1))
{
	BuildItemsArrayIfNeeded(this);

	TradeItem item;
	item.name = name;
	item.iconName = iconName;
	item.configFilename = configFilename;
	item.AddDescription(description);
	item.instantShipping = instantShipping;
	item.isSeparator = false;
	item.separatorIconSize = iconSize;
	
	this.push("items", item);
	TradeItem@ p_ref;
	this.getLast("items", @p_ref);
	return p_ref;
}