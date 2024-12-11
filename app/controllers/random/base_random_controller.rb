class Random::BaseRandomController < BaseDualDomainController

  private

  def solo_domain
    ENV['RANDOM_DOMAIN']
  end

  def feature_name
    'random'
  end

  def shuffle(seed, items)
    hash = hash_with_secret([seed, items])
    shuffled_items = items.shuffle(random: Random.new(hash.to_i(16)))
    [shuffled_items, hash]
  end

  def hash_with_secret(array)
    secret = ENV['SECRET_RANDOM_SEED']
    raise 'SECRET_RANDOM_SEED environment variable is required' unless secret
    Digest::SHA512.hexdigest(array.join(':') + ':' + secret)
  end

end