# tag cloud code inspired by this article
#  http://www.juixe.com/techknow/index.php/2006/07/15/acts-as-taggable-tag-cloud/

class TagCloud
  def initialize(user, options = {})
    @user = user
    @cut_off = options[:cut_off]
    @levels=10
  end

  def divisor
    @divisor ||= ((max - min) / @levels) + 1
  end

  def tags
    @tags ||= tag_query.sort_by { |tag| tag.name.downcase }
  end

  def min
    @min ||= 0 || tag_counts.min
  end

  def max
    @max ||= tag_counts.max || 0
  end

  private

  def tag_query
    Tag.select('tags.id, name, count(*) AS count').
        from('taggings, tags, todos').
        where('tags.id = tag_id').
        where('taggings.taggable_id = todos.id').
        where("todos.user_id= #{@user.id}").
        where('taggings.taggable_type="Todo"').
        where(cutoff_condition).
        group('tags.id, tags.name').
        order('count DESC, name').
        limit(100)
  end

  def cutoff_condition
    return nil if @cut_off.nil?

    ["(todos.created_at > :cut_off OR todos.completed_at > :cut_off)", cut_off: @cut_off]
  end

  def tag_counts
    @tag_counts ||= tags.map {|tag| tag.count.to_i }
  end
end