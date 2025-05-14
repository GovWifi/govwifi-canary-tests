RSpec.shared_context "radius", shared_context: :metadata do
  before(:all) do
    unless  ENV["RADIUS_KEY"] && ENV["RADIUS_IPS"] && ENV["EAP_TLS_CLIENT_CERT"] && ENV["EAP_TLS_CLIENT_KEY"]
      abort "\e[31mMust define RADIUS_KEY, RADIUS_IPS, EAP_TLS_CLIENT_CERT and EAP_TLS_CLIENT_KEY\e[0m"
    end
  end
end
