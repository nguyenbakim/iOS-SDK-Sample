
#include "EffectSampleFactory.h"


namespace EffectSample {
class EffectSampleInfo : public oovoo::sdk::plugin_info
{
	OOVOO_CLASS(EffectSampleInfo, oovoo::sdk::plugin_info, "{d048debe-8056-4069-9672-7ceead89a730}");


public:
	EffectSampleInfo(const std::string& internal_id, const std::string& displayName,
					 const  oovoo::sdk::plugin_info::Type t = oovoo::sdk::plugin_info::UNKNOWN, oovoo::sdk::plugin_factory* f = nullptr)
	{
		_internal_id = internal_id;
		_id = "";
		_type = t;
		_state = oovoo::sdk::plugin_info::NOT_CREATED;
		_factory = f;
		_name = displayName;
	}

	virtual Type  type() const
	{
		return _type;
	}

	const char* id() const
	{
		return _id.c_str();
	}
	const char* internal_id() const
	{
		return _internal_id.c_str();
	}
	const char* display_name() const
	{
		return _name.c_str();
	}

	oovoo::sdk::object_ptr<oovoo::sdk::plugin_factory> factory() const
	{
		return _factory;
	}

	State state() const
	{
		return _state;
	}
	void  state(const State s)
	{
		_state = s;
	}

	const char* parameters() const
	{
		return  "{}";
	}
	void parameters(const char* json_params)
	{
		;
	}
	void update_parameters(const char* json_params)
	{
		;
	}

	bool is_back() const
	{
		return false;    // for video_capture
	}
	const char* url() const
	{
		return "";    // for video_effect
	}
	virtual bool is_default() const override
	{
		return _is_default;
	}
	virtual const char* category() const override { return ""; }


private:
	std::string _internal_id;
	std::string _id;
	std::string _name;
	oovoo::sdk::plugin_factory::ptr _factory;
	oovoo::sdk::plugin_info::State _state;
	oovoo::sdk::plugin_info::Type _type;
	bool        _is_default;
};

EffectSampleFactory::EffectSampleFactory()
{
}

EffectSampleFactory::~EffectSampleFactory()
{
}


oovoo::sdk::sdk_error EffectSampleFactory::load(oovoo::sdk::plugin_registrator::ptr plugin_manager)
{
	EffectSampleInfo::ptr info = oovoo::sdk::make_object< EffectSampleInfo >("EffectSample-VIDEO-EFFECT", "EffectSample", oovoo::sdk::plugin_info::VIDEO_EFFECT, this);
	plugin_manager->register_plugin(info);
	return oovoo::sdk::sdk_error::OK;
}

oovoo::sdk::sdk_error EffectSampleFactory::unload()
{
	return oovoo::sdk::sdk_error::OK;
}

oovoo::sdk::plugin::ptr EffectSampleFactory::create_plugin_instance(oovoo::sdk::plugin_info::ptr info)
{
	switch (info->type())
	{
		case oovoo::sdk::plugin_info::VIDEO_EFFECT:
			return _videoEffect = oovoo::sdk::make_object<EffectPlugin>(info);
	}

	return nullptr;
}

oovoo::sdk::plugin_factory::ptr EffectSampleFactory::createPluginFactory()
{
	oovoo::sdk::plugin_factory::ptr factory = oovoo::sdk::make_object<EffectSample::EffectSampleFactory>();
	//EffectSample::EffectSampleFactory::ptr testFac = oovoo::sdk::make_object<EffectSample::EffectSampleFactory>();
	return factory;
}

}
