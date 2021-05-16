class Markov
  ENDMARK = '%END%'
  CHAIN_MAX = 30

  def initialize
    @dictionary = {}
    @starts = {}
  end

  def load(f)
    @dictionary = Marshal::load(f)
    @starts = Marshal::load(f)
  end

  def save(f)
    Marshal::dump(@dictionary, f)
    Marshal::dump(@starts, f)
  end

  def add_sentence(parts)
    return if parts.size < 3

    add_start(parts[0])

    parts.each_cons(3) do |prefix1, prefix2, suffix|
      add_suffix(prefix1, prefix2, suffix)
    end

    add_suffix(parts[-2], parts[-1], ENDMARK)
  end

  def generate(keyword)
    return nil if @dictionary.empty?

    words = []
    prefix1 = (@dictionary[keyword]) ? keyword : select_start
    prefix2 = @dictionary[prefix1].keys.sample
    words.push(prefix1, prefix2)

    CHAIN_MAX.times do
      suffix = @dictionary[prefix1][prefix2].sample
      break if suffix == ENDMARK

      words.push(suffix)
      prefix1, prefix2 = prefix2, suffix
    end

    words.join
  end

  private

  def add_suffix(prefix1, prefix2, suffix)
    @dictionary[prefix1] = {} unless @dictionary[prefix1]
    @dictionary[prefix1][prefix2] = [] unless @dictionary[prefix1][prefix2]
    @dictionary[prefix1][prefix2].push(suffix)
  end

  def add_start(prefix1)
    @starts[prefix1] = 0 unless @starts[prefix1]
    @starts[prefix1] += 1
  end

  def select_start
    @starts.keys.sample
  end
end
