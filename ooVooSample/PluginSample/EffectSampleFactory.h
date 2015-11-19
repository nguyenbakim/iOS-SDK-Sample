#include "EffectPlugin.h"

namespace EffectSample {

class EffectSampleFactory : public oovoo::sdk::plugin_factory
{
	OOVOO_CLASS(EffectSampleFactory, oovoo::sdk::plugin_factory, "{b27df165-ff88-44f4-bced-bbf865c70907}");

public:
	EffectSampleFactory();
	virtual ~EffectSampleFactory();

	virtual oovoo::sdk::sdk_error load(oovoo::sdk::plugin_registrator::ptr plugin_manager);
	virtual oovoo::sdk::sdk_error unload();

	virtual oovoo::sdk::plugin::ptr create_plugin_instance(oovoo::sdk::plugin_info::ptr info);

	virtual const char* name() const
	{
		return "EffectSample";
	}
	virtual const char* version() const
	{
		return "1.0.0";
	};

	static oovoo::sdk::plugin_factory::ptr createPluginFactory();
protected:
	EffectPlugin::ptr _videoEffect;
};

}