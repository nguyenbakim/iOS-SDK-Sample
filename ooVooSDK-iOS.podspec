Pod::Spec.new do |s|                            										
  s.name         = "ooVooSDK-iOS"                                                                                                
  s.version      = "1.5.0"                                                                                 
  s.summary      = "ooVooSDK provides a video chat library for iOS"                                                            
  s.homepage     = "https://developer.oovoo.com"                                                                             
  s.license      = { :type => "Commercial", :text => ""}                                                                     
  s.author             = { "ooVoo LLC" => "sdk.support@oovoo.com" }                                                          
  s.social_media_url   = "https://twitter.com/oovoodev"                                                                      
  s.platform      = :ios, "7.0"                                                                                              
  s.source        = { :git => "https://github.com/oovoodev/iOS-SDK-Sample.git", :tag => "1.5.0.73" } 
  s.source_files      = "ooVooSDK-iOS.framework/Headers/*.h"                                                                        
  s.preserve_path = "ooVooSDK-iOS.framework/*"                                                                                      
  s.vendored_frameworks = "ooVooSDK-iOS.framework"                                                                                  
  s.frameworks    = "UIKit"                                                                                                  
  s.requires_arc = true                                                                                                      
end  
