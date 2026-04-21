stripe_secret_key = ENV["STRIPE_SECRET_KEY"]

if stripe_secret_key.blank?
  env_file = Rails.root.join(".env")

  if File.exist?(env_file)
    env_line = File.readlines(env_file).find { |line| line.strip.start_with?("STRIPE_SECRET_KEY=") }

    if env_line.present?
      stripe_secret_key = env_line.split("=", 2).last.to_s.strip.delete_prefix('"').delete_suffix('"').delete_prefix("'").delete_suffix("'")
    end
  end
end

Stripe.api_key = stripe_secret_key
