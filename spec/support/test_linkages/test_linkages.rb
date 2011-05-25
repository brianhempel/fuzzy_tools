class TestLinkages
  def initialize(options = {})
    @rows = load
  end
  
  def load
    raise NotImplimentedError
  end
  
  def headers
    raise NotImplimentedError
  end
  
  def col(name)
    n = headers.index(name)
    @rows.map { |row| row[n] }
  end
  
  def query_to_targets(query_col, target_col)
    query_col_n  = headers.index(query_col)
    target_col_n = headers.index(target_col)
    
    {}.tap do |map|
      @rows.each do |row|
        query  = row[query_col_n]
        target = row[target_col_n]
        map[query] ||= []
        map[query] << target
      end
    end
  end
  
  def each_column_pair
    headers.permutation(2).each do |query_col, target_col|
      yield(query_col, target_col)
    end
  end
  
  def each_linkage
    each_column_pair do |query_col, target_col|
       query_to_targets(query_col, target_col).each do |query, targets|
         yield(query, targets, col(target_col), target_col)
       end
     end
  end
  
  def all_values_anywhere
    values = []
    headers.each { |name| values += col(name) }
    values.uniq
  end
end