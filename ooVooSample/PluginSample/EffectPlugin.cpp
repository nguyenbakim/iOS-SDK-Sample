#include "EffectPlugin.h"

namespace EffectSample {
EffectPlugin::EffectPlugin(oovoo::sdk::plugin_info::ptr info)
{
	_info = info;
	_instance_id = "abcdeffff";
}


EffectPlugin::~EffectPlugin()
{
}

oovoo::sdk::video_frame::ptr EffectPlugin::process(oovoo::sdk::video_frame::ptr frame)
{
    if(!frame)
    {
        return frame;
    }
    
    {
        auto data = frame->get_video_data();
        if (!data)
        {
            return frame;
        }
        
        oovoo::sdk::color_format f = frame->format();
        int w = frame->width();
        int h = frame->height();
        switch(f)
        {
            case oovoo::sdk::YUV420:
            for (int i = 1; i < data->num_planes(); i++)
            {
                memset(data->plane_ptr(i), 255, data->plane_pitch(i) * h/2);
            }
            break;
            case oovoo::sdk::BGR32:
            {
                int frame_size = w*h*4;
                memset((uint8_t*)data->data() + frame_size/2*((frame->frame_number()/30)%2), 255, frame_size/2);
            }
            break;
        }
    }
    
    return frame;
}

const char* EffectPlugin::category() const
{
	return _info->category();
}

}