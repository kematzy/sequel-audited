require_relative "../../spec_helper"
require_relative "../../../lib/sequel/plugins/audited"

class CurrentUserMethodTest < Minitest::Spec

  describe "current_user" do

    it "should by default return the default user - Joe Blogs" do
      current_user().must_equal User.first
      current_user().id.must_equal 1
      current_user().name.must_equal "Joe Blogs"
      current_user().username.must_equal "joeblogs"
    end

    it "should allow overriding the user and return the new current_user - Jane Blogs" do
      $current_user =           User[2]
      current_user().wont_equal User[1]
      current_user().must_equal User[2]
      current_user().name.must_equal "Jane Blogs"
      current_user().username.must_equal "janeblogs"
      $current_user = User[1]  # reset for next test
    end

  end

end

class AuditedUserMethodTest < Minitest::Spec

  describe "audited_user" do

    it "should by default return the default user - Audited User" do
      audited_user().must_equal User[3]
      audited_user().name.must_equal "Audited User"
      audited_user().username.must_equal "auditeduser"
    end

    it "should allow overriding the user and return the new current_user - Jane Blogs" do
      $audited_user = User[2]
      audited_user().wont_equal User.first
      audited_user().must_equal User[2]
      audited_user().name.must_equal "Jane Blogs"
      audited_user().username.must_equal "janeblogs"
      $audited_user = User[3]  # reset for next test
    end

  end

end

class SequelAuditedPluginTest < Minitest::Spec

  describe "configuration" do

    describe "without options passed" do

      before do
        @p = Class.new(Post)
        @p.plugin(:audited)
      end

      describe "#audited_columns" do

        it "should include all fields, excluding default ignored attributes" do
          @p.audited_columns.must_equal [:id, :category_id, :title, :body, :urlslug, :author_id, :uuid]
        end

      end

      describe "#non_audited_columns" do

        it "should include the default excluded attributes" do
          @p.non_audited_columns.must_equal [:created_at, :updated_at]
        end

      end

      describe "#audited_default_ignored_columns" do

        [:lock_version, :created_at, :updated_at, :created_on, :updated_on].each do |m|
          it "should include: #{m}" do
            @p.audited_default_ignored_columns.must_include(m)
          end

        end

      end

      describe "#audited_current_user_method" do

        it "should return the default value: :current_user" do
          @p.audited_current_user_method.must_equal :current_user
        end

        it "should use the :current_user User for versions" do
          Category.plugin(:audited)
          c = Category.create(name: "Category #audited_current_user_method")
          # c.must_equal ''
          assert c.valid?
          v = c.versions.first
          # v.must_equal ''
          v.username.must_equal User[1].username
        end

      end

    end # /without options

    describe "with options" do

      describe "Post.plugin(:audited, :user_method => :audited_user)" do
        before do
          ::AuditLog.where(item_type: "Category").destroy
          ::DB[:categories].delete
          @p = Class.new(Post)
          @p.plugin(:audited, user_method: :audited_user)
        end

        it "#audited_current_user_method should return the custom value" do
          @p.audited_current_user_method.must_equal :audited_user
        end

        it "should use the :audited_user User for versions" do
          Category.plugin(:audited, user_method: :audited_user)
          c = Category.create(name: "Category created by AuditedUser")
          # c.must_equal ''
          assert c.valid?
          v = c.versions.first
          # v.must_equal ''
          v.username.must_equal "auditeduser"

          # assert_equal "debug", AuditLog.all.inspect
        end

      end

      describe "Post.plugin(:audited, :only => ...)" do

        describe ":only => :title" do

          before do
            ::AuditLog.where(item_type: "Post").destroy
            ::DB[:posts].delete
            @p = nil
            @p = Class.new(Post)
            @p.plugin(:audited, only: :title)
          end

          it "#.audited_columns should include only the named column" do
            @p.audited_columns.must_equal [:title]
          end

          it "#.non_audited_columns should include all column except the named column" do
            @p.non_audited_columns.must_equal(@p.columns - [:title])
          end

          it "should only store the :title for update versions" do
            Post.plugin(:audited, only: :title)
            p = Post.create(title: "Post Title", body: "Post Body", category_id: 1)
            p.versions.wont_equal []
            p.update(title: "Post Title Updated")
            p.versions.count.must_equal 2
            v = p.versions.last
            v.event_data.must_equal({"title"=>"Post Title Updated"})
          end

          it "should not store version for non :title updates" do
            Post.plugin(:audited, only: :title)
            p = Post.create(title: "Post Title", body: "Post Body", category_id: 1)
            p.versions.count.must_equal 1
            p.update(body: "Post Body Updated")
            p.versions.count.must_equal 1
            v = p.versions.last
            v.event.must_equal "create"
          end

        end

        describe "only: [:title]" do

          before do
            @p = nil
            @p = Class.new(Post)
            @p.plugin(:audited, only: [:title])
          end

          it "#.audited_columns should include only the named column" do
            @p.audited_columns.must_equal [:title]
          end

          it "#.non_audited_columns should include all column except the named column" do
            @p.non_audited_columns.must_equal(@p.columns - [:title])
          end

        end

        describe "only: [:title, :author_id]" do

          before do
            ::AuditLog.where(item_type: "Post").destroy
            ::DB[:blog_posts].delete
            @p = nil
            @p = Class.new(BlogPost)
            @p.plugin(:audited, only: [:title, :author_id])
          end

          it "#.audited_columns should include only the named columns" do
            @p.audited_columns.must_equal [:title, :author_id]
          end

          it "#.non_audited_columns should include all column except the named columns" do
            @p.non_audited_columns.must_equal(@p.columns - [:title, :author_id])
          end

          it "#.versions should only store the :title for update versions" do
            BlogPost.plugin(:audited, only: [:title, :author_id])
            p = BlogPost.create(title: "should only store the :title for update versions", body: "Post Body", category_id: 1, author: current_user())
            p.versions.count.must_equal 1
            # puts "\nTesting Post.versions: [#{p.versions.inspect}]\n"
            p.update(title: "Post Title Updated [:title, :author_id]", author: audited_user() )
            # puts "\nTesting Post after update: [#{p.inspect}]\n"
            # puts "\nTesting Post.versions after update: [#{p.versions.inspect}]\n"
            p.versions.count.must_equal 2
            v = p.versions.last
            # puts v.inspect
            v.event_data.must_equal({"title"=>"Post Title Updated [:title, :author_id]", "author_id" => 3 })
          end

        end

      end

      describe "Post.plugin(:audited, :except => ...)" do

        describe ":except => :title" do

          before do
            # ::AuditLog.where(item_type: "Post").destroy
            @p = Class.new(Post)
            @p.plugin(:audited, except: :title)
          end

          it "#.audited_columns should include all columns except the named column" do
            @p.audited_columns.must_equal([:id, :category_id, :body, :urlslug, :author_id, :uuid])
          end

          it "#.non_audited_columns should include the named column" do
            @p.non_audited_columns.must_equal([:title, :created_at, :updated_at])
          end

          # it 'should store all attributes except :title for update versions' do
          #   Post.plugin(:audited, except: :title)
          #   p = Post.create(title: 'Post Title', body: 'Post Body', category_id: 1)
          #   p.versions.wont_equal []
          #   p.update(body: 'Post Body Updated')
          #   p.versions.count.must_equal 2
          #   v = p.versions.last
          #   v.event_data.must_equal({"body"=>"Post Body Updated"})
          # end
          #
          # it 'should not store version for :title updates' do
          #   Post.plugin(:audited, except: :title)
          #   p = Post.create(title: 'Post Title', body: 'Post Body', category_id: 1)
          #   p.versions.count.must_equal 1
          #   p.update(title: 'Post Title Updated')
          #   p.versions.count.must_equal 1
          #   v = p.versions.last
          #   # v.must_equal 'debug'
          #   v.event.must_equal 'create'
          # end

        end

        describe "except: [:title]" do

          before do
            # ::AuditLog.where(item_type: "Post").destroy
            @p = Class.new(Post)
            @p.plugin(:audited, except: [:title])
          end

          it "#.audited_columns should include all columns except the named column" do
            @p.audited_columns.must_equal([:id, :category_id, :body, :urlslug, :author_id, :uuid])
          end

          it "#.non_audited_columns should include the named column" do
            @p.non_audited_columns.must_equal([:title, :created_at, :updated_at])
          end

        end

        describe "except: [:title,:author_id]" do

          before do
            # ::AuditLog.where(item_type: "Post").destroy
            @p = Class.new(Post)
            @p.plugin(:audited, except: [:title, :author_id])
          end

          it "#.audited_columns should include only the excepted columns" do
            @p.audited_columns.must_equal([:id, :category_id, :body, :urlslug, :uuid])
          end

          it "#.non_audited_columns should include the excluded columns" do
            @p.non_audited_columns.must_equal([:title, :author_id, :created_at, :updated_at])
          end

        end

      end

      describe "Post.plugin(:audited, :default_ignored_columns => [])" do
        before do
          # ::AuditLog.where(item_type: "Post").destroy
          @p = Class.new(Post)
          @p.plugin(:audited, default_ignored_columns: [:title, :author_id])
        end

        it "#audited_default_ignored_columns should return the custom value" do
          @p.audited_default_ignored_columns.must_equal [:title, :author_id]
        end

        it "#audited_columns should return the correct columns" do
          @p.audited_columns.must_equal [:id, :category_id, :body, :urlslug, :created_at, :updated_at, :uuid]
        end

        it "#audited_ignored_columns should return the correct ignored columns" do
          @p.audited_ignored_columns.must_equal [:title, :author_id]
        end

      end

    end

  end

  describe "An audited Model :Author" do

    before do
      Author.plugin(:audited, only: :name)
      Category.plugin(:audited, only: :name)
    end

    describe "Class Methods" do

      describe "#.audited_versions?" do
        before do
          ::DB[:authors].delete
          ::AuditLog.where(item_type: "Author").delete
        end

        it "should return false when no versions have been created" do
          # skip
          Author.audited_versions?.must_equal false
        end

        it "should return true if one version have been created" do
          a = Author.create(name: "Kematzy")
          a.versions.count.must_equal 1
          Author.audited_versions?.must_equal true
        end

        it "should return true if multiple versions have been created" do
          Author.audited_versions.count.must_equal 0

          a = Author.create(name: "Kematzy")
          a.versions.count.must_equal 1
          Author.audited_versions.count.must_equal 1


          a.name = "Kematzy 2"
          a.save
          Author.audited_versions.count.must_equal 2
          # forcing uncached query here
          a.versions(true).count.must_equal 2


          a.update(name: "Kematzy 3")
          Author.audited_versions.count.must_equal 3
          # forcing uncached query here
          a.versions(true).count.must_equal 3


          a.set_fields({name: "Kematzy 4"}, [:name], missing: :skip)
          a.save

          Author.audited_versions.count.must_equal 4
          # forcing uncached query here
          a.versions(true).count.must_equal 4

          Author.audited_versions?.must_equal true
        end

      end

      describe "#.audited_versions" do

        describe "without options" do
          before do
            ::DB[:authors].delete
            ::AuditLog.where(item_type: "Author").delete
          end

          it "should return an empty array when no versions exists" do
            Author.audited_versions.must_equal []
          end

          it "should return an array of versions if one version have been created" do
            a = Author.create(name: "Kematzy")
            Author.audited_versions.wont_be_empty
            al = Author.audited_versions.first
            # al.must_equal ''
            al.must_be_kind_of(::AuditLog)
            al.item_type.must_equal "Author"
            al.item_uuid.must_equal a.uuid
          end

        end

        describe "with options" do

          before do
            ::DB[:authors].delete
            ::DB[:categories].delete
            ::AuditLog.where(item_type: "Author").destroy
            ::AuditLog.where(item_type: "Category").destroy

            %w(a b c d).each do |n|
              Author.create(name: "Joe #{n}")
              Category.create(name: "Category #{n}")
            end
            @pkA = Author.last
            @pkC = Category.last
          end

          describe "(username: ??)" do

            it "should return an empty array when given a user without audits" do
              Author.audited_versions(username: "janeblogs").must_equal []
              Author.audited_versions(username: "janeblogs").count.must_equal 0
            end

            it "should return found audits when given a user with audits" do
              # AuditLog.all.must_equal ''
              Author.audited_versions(username: "joeblogs").count.must_equal 4
            end

            it "should return the correct number of versions of another audited user" do
              $current_user = User[2]
              Author.last.update(name: "User 2")
              Category.last.update(name: "User 2")
              $current_user = User[1] # reset

              Author.audited_versions(username: "janeblogs").count.must_equal 1
              AuditLog.where(username: "janeblogs").count.must_equal 2
            end

          end

          describe "(item_uuid: ??)" do

            it "should return an empty array when given a model uuid key without audits" do
              Author.audited_versions(item_uuid: "abc-123").must_equal []
              Author.audited_versions(item_uuid: "abc-123").count.must_equal 0
            end

            it "should return found audits when given an audited uuid key" do
              Author.audited_versions(item_uuid: @pkA.uuid).count.must_equal 1
              Category.audited_versions(item_uuid: @pkC.uuid).count.must_equal 1
            end

          end

          describe "(created_at: ???)" do

            it "should return an empty array when given a time without audits" do
              Author.audited_versions(created_at: Time.now - 1 ).must_equal []
              Author.audited_versions(created_at: Time.now - 1 ).count.must_equal 0
            end

            it "should return an array when given a time with audits" do
              skip("TODO: have to add TimeCop here to test the time issues")

              Author.audited_versions(created_at: Time.now).must_equal []
              Author.audited_versions(created_at: Time.now).count.must_equal 1
            end

          end

        end

      end

    end

    describe "Instance Methods" do

      describe "#.blame (aliased as: #.last_audited_by)" do
        before do
          ::DB[:authors].delete
          ::AuditLog.where(item_type: "Author").destroy
        end

        it "should return 'not audited' if no previous version" do
          a = Author.new
          a.blame.must_equal "not audited"
          a.last_audited_by.must_equal "not audited"
        end

        it "should return the username of the last version" do
          a = Author.create(name: "Jane")
          a.blame.must_equal "joeblogs" # default
          a.last_audited_by.must_equal "joeblogs"
        end

      end

      describe "#.last_audited_at (aliased as: #.last_audited_on)" do
        before do
          ::DB[:authors].delete
          ::AuditLog.where(item_type: "Author").destroy
        end

        it "should return 'not audited' if no previous version" do
          a = Author.new
          a.last_audited_at.must_equal "not audited"
          a.last_audited_on.must_equal "not audited"
        end

        it "should return the created_at time of the last version" do
          a = Author.create(name: "Author .last_audited_at")
          a.last_audited_at.must_be_kind_of(Time)
          a.last_audited_at.to_s.must_match(/#{Time.now.strftime("%Y-%m-%d")}/)
        end

      end

      describe "Hooks" do
        before do
          ::DB[:categories].delete
          ::AuditLog.where(item_type: "Category").destroy
          Category.plugin(:audited, only: [:name])
        end

        describe "when creating a record, triggering #.after_create" do

          it "should save an audited version" do
            c = Category.new(name: "Category .after_create")
            c.versions.must_equal []
            c.versions.count.must_equal 0
            c.save
            c.versions.count.must_equal 1

            v = c.versions.first
            v.version.must_equal 1
            v.event.must_equal "create"
            v.item_type.must_equal c.class.to_s
            v.item_uuid.must_equal c.uuid
            v.event_data.wont_equal ''
            # v.changed.must_equal c.values.to_json
          end

        end

        describe "when updating a record, triggering #.after_update" do
          before do
            ::DB[:categories].delete
            ::AuditLog.where(item_type: "Category").destroy
          end

          it "should save an audited version with changes only" do
            c = Category.create(name: "Category .after_update")
            assert c.valid?
            c.versions.count.must_equal 1

            c.update(name: "Category .after_update updated")
            c.versions.count.must_equal 2

            v = c.versions.last
            v.version.must_equal 2
            v.event.must_equal "update"
            v.item_type.must_equal c.class.to_s
            v.item_uuid.must_equal c.uuid
            v.event_data.to_json.must_match(/\"name\":\"Category \.after_update updated\"/)
          end

        end


        describe "when destroying a record, triggering #.after_destroy" do
          before do
            ::DB[:categories].delete
            ::AuditLog.where(item_type: "Category").destroy
          end

          it "should save an audited version with all values" do
            c = Category.create(name: "Category .after_destroy")
            assert c.valid?
            c.versions.count.must_equal 1

            c.update(name: "Category .after_destroy updated")
            c.versions.count.must_equal 2

            c.destroy
            c.versions.count.must_equal 3

            v = c.versions.last
            # v.must_equal 'debug'
            v.version.must_equal 3
            v.event.must_equal "destroy"
            v.item_type.must_equal c.class.to_s
            v.item_uuid.must_equal c.uuid
            v.event_data.to_json.must_equal c.values.to_json
          end

        end

      end

    end

    describe "should have associated versions" do

      it { assert_association_one_to_many(Author.new, :versions) }

      before do
        ::DB[:authors].delete
        ::AuditLog.where(item_type: "User").destroy
        ::AuditLog.where(item_type: "Author").destroy
        @u = User.create(username: "johnblogs", name: "John Blogs", email: "john@blogs.com")
      end

      it "should store the current user :username for each version" do
        $current_user = @u
        a = Author.create(name: "Kematzy")
        v = a.versions.first
        v.username.must_equal "johnblogs"
        $current_user = User[1]  # reset
      end

      it "should store the current user :id for each version" do
        $current_user = User[2]  # jane
        a = Author.create(name: "Kematzy")
        v = a.versions.first
        v.user_id.must_equal 2
        $current_user = User[1]  # reset
      end

      it "should not store versions for unsaved models" do
        m = Author.new
        m.versions.count.must_equal 0
        m.versions.must_equal []
      end

    end

  end


  describe "with Custom user method" do
    before do
      ::DB[:authors].delete
      ::AuditLog.where(item_type: "Author").destroy
      Author.plugin(:audited, only: :name, user_method: :audited_user)
    end

    it "should" do
      # ::AuditLog.audited_current_user_method = :audited_user
      a = Author.create(name: "Kematzy")
      # a.versions.must_equal ''
      v = a.versions.first
      v.username.must_equal "auditeduser"
      # ::AuditLog.audited_current_user_method = :current_user
    end

  end


end
