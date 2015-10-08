#ifdef _WINRT_DLL
#include "ooVooApi/api/cpp/plugins.h"
#else
#ifdef ANDROID
#include "pluginapi/plugins.h"
#else
#include "ooVooSDK/plugins.h"
#endif
#endif

namespace EffectSample {
class EffectPlugin : public oovoo::sdk::video_effect
{
	OOVOO_CLASS(EffectPlugin, oovoo::sdk::video_effect, "{bc06d2ef-c2d1-4190-9f41-c58b5603535d}");
	bool        _is_default;

public:
	EffectPlugin(oovoo::sdk::plugin_info::ptr info);
	virtual ~EffectPlugin();

	//video_effect
	virtual oovoo::sdk::video_frame::ptr process(oovoo::sdk::video_frame::ptr frame);

	// plugin
	virtual const char* instance_id() override
	{
		return _instance_id.c_str();
	}

	// plugin_info
	virtual oovoo::sdk::plugin_info::Type type() const
	{
		return _info->type();
	}
	virtual oovoo::sdk::plugin_info::State state() const
	{
		return _info->state();
	}
	virtual void state(const oovoo::sdk::plugin_info::State s)
	{
		_info->state(s);
	}
	virtual const char* id() const
	{
		return _info->id();
	}
	virtual const char* internal_id() const
	{
		return _info->internal_id();
	}
	virtual const char* display_name() const
	{
		return _info->display_name();
	}
	virtual oovoo::sdk::plugin_factory::ptr factory() const
	{
		return _info->factory();
	}
	virtual void parameters(const char* json_params) override {};
	virtual const char* parameters() const override
	{
		return _info->parameters();
	}
	virtual void update_parameters(const char* json_params) override {};
	virtual bool is_default() const override
	{
		return _is_default;
	}
	virtual const char* category() const override;


	virtual void destroyResources() { /*TODO: implement function*/ }
private:
	std::string        _instance_id;
	oovoo::sdk::plugin_info::ptr   _info;
};
}
