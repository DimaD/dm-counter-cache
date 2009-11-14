require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe DataMapper::CounterCacheable do
  context "when attribute with counter_cache declared twice" do
    module Multiple
      class Post
        include DataMapper::Resource

        property :id, Integer, :serial => true
        property :comments_count, Integer, :default => 0
        has n, :comments, :class_name => 'Multiple::Comment'
      end

      class Comment
        include DataMapper::Resource
        include DataMapper::CounterCacheable

        property :id, Integer, :serial => true
        belongs_to :post, :class_name => 'Multiple::Post', :counter_cache => :comments_count
        belongs_to :post, :class_name => 'Multiple::Post', :counter_cache => :comments_count
      end

      Comment.auto_migrate!
      Post.auto_migrate!
    end

    before :each do
      @post = Multiple::Post.create
    end

    it "should increment counter only once" do
      lambda do
        @post.comments.create
        @post.reload
      end.should change(@post, :comments_count).by(+1)
    end

    it "should decrement counter only once" do
      comment1 = @post.comments.create
      comment2 = @post.comments.create
      @post.reload

      lambda do
        comment1.destroy
        @post.reload
      end.should change(@post, :comments_count).by(-1)
    end

  end
end
