require_relative '../../spec_helper'
require_relative '../../../lib/sequel/plugins/audited'

class CurrentUserMethodTest < Minitest::Spec
  
  describe 'current_user' do
    
    it 'should by default return the default user - Joe Blogs' do
      current_user().must_equal User.first
    end
    
    it 'should allow overriding the user and return the new current_user - Jane Blogs' do
      $current_user =           User[2]
      current_user().wont_equal User[1]
      current_user().must_equal User[2]
      current_user().username.must_equal 'janeblogs'
      $current_user = User[1]  # reset for next test
    end
    
  end
  
end

class AuditedUserMethodTest < Minitest::Spec
  
  describe 'audited_user' do
    
    it 'should by default return the default user - Joe Blogs' do
      audited_user().must_equal User[3]
      audited_user().username.must_equal 'auditeduser'
    end
    
    it 'should allow overriding the user and return the new current_user - Jane Blogs' do
      $audited_user = User[2]
      audited_user().wont_equal User.first
      audited_user().must_equal User[2]
      audited_user().username.must_equal 'janeblogs'
      $audited_user = User[3]  # reset for next test
    end
    
  end
  
end

class SequelAuditedPluginTest < Minitest::Spec
  
  describe 'configuration' do
    
    describe 'without options passed' do
      before do 
        @p = Class.new(Post)
        @p.plugin(:audited)
      end
      
      describe '#audited_columns' do
        
        it 'should include all fields, excluding default ignored attributes' do
          @p.audited_columns.must_equal [:id, :category_id, :title, :body, :author_id]
        end
        
      end
      
      describe '#non_audited_columns' do
        
        it 'should include the default excluded attributes' do
          @p.non_audited_columns.must_equal [:created_at, :updated_at]
        end
        
      end
      
      describe '#audited_default_ignored_columns' do
        
        [:lock_version, :created_at, :updated_at, :created_on, :updated_on].each do |m|
          it "should include: #{m}" do
            @p.audited_default_ignored_columns.must_include(m)
          end
          
        end
        
      end
      
      describe '#audited_current_user_method' do
        it 'should return the default value: :current_user' do
          @p.audited_current_user_method.must_equal :current_user
        end
      end
      
    end # /without options
    
    describe 'with options' do
      
      describe 'Post.plugin(:audited, :only => ...)' do
        
        describe ':only => :title' do
          before do
            @p = Class.new(Post)
            @p.plugin(:audited, only: :title)
          end
          
          it '#.audited_columns should include only the named column' do
            @p.audited_columns.must_equal [:title]
          end
          
          it '#.non_audited_columns should include all column except the named column' do
            @p.non_audited_columns.must_equal(@p.columns - [:title])
          end
          
        end
        
        describe 'only: [:title]' do
          before do
            @p = Class.new(Post)
            @p.plugin(:audited, only: [:title])
          end
          
          it '#.audited_columns should include only the named column' do
            @p.audited_columns.must_equal [:title]
          end
          
          it '#.non_audited_columns should include all column except the named column' do
            @p.non_audited_columns.must_equal(@p.columns - [:title])
          end
          
        end
        
        describe 'only: [:title,:author_id]' do
          before do
            @p = Class.new(Post)
            @p.plugin(:audited, only: [:title, :author_id])
          end
          
          it '#.audited_columns should include only the named columns' do
            @p.audited_columns.must_equal [:title, :author_id]
          end
          
          it '#.non_audited_columns should include all column except the named columns' do
            @p.non_audited_columns.must_equal(@p.columns - [:title, :author_id])
          end
          
        end
        
      end
      
      describe 'Post.plugin(:audited, :except => ...)' do
        
        describe ':except => :title' do
          before do
            @p = Class.new(Post)
            @p.plugin(:audited, except: :title)
          end
          
          it '#.audited_columns should include all columns except the named column' do
            @p.audited_columns.must_equal([:id, :category_id, :body, :author_id])
          end
          
          it '#.non_audited_columns should include the named column' do
            @p.non_audited_columns.must_equal([:title, :created_at, :updated_at])
          end
          
        end
        
        describe 'except: [:title]' do
          before do
            @p = Class.new(Post)
            @p.plugin(:audited, except: [:title])
          end
          
          it '#.audited_columns should include all columns except the named column' do
            @p.audited_columns.must_equal([:id, :category_id, :body, :author_id])
          end
          
          it '#.non_audited_columns should include the named column' do
            @p.non_audited_columns.must_equal([:title, :created_at, :updated_at])
          end
          
        end
        
        describe 'except: [:title,:author_id]' do
          before do
            @p = Class.new(Post)
            @p.plugin(:audited, except: [:title, :author_id])
          end
          
          it '#.audited_columns should include only the excepted columns' do
            @p.audited_columns.must_equal([:id, :category_id, :body])
          end
          
          it '#.non_audited_columns should include the excluded columns' do
            @p.non_audited_columns.must_equal([:title, :author_id, :created_at, :updated_at])
          end
          
        end
        
      end
      
      describe 'Post.plugin(:audited, :user_method => :audited_user)' do
        before do
          @p = Class.new(Post)
          @p.plugin(:audited, user_method: :audited_user)
        end
        
        it '#audited_current_user_method should return the custom value' do
          @p.audited_current_user_method.must_equal :audited_user
        end
        
      end
      
      describe 'Post.plugin(:audited, :default_ignored_columns => [])' do
        before do
          @p = Class.new(Post)
          @p.plugin(:audited, default_ignored_columns: [:title, :author_id])
        end
        
        it '#audited_default_ignored_columns should return the custom value' do
          @p.audited_default_ignored_columns.must_equal [:title, :author_id]
        end
        
        it '#audited_columns should return the correct columns' do
          @p.audited_columns.must_equal [:id, :category_id, :body, :created_at, :updated_at]
        end
        
        it '#audited_ignored_columns should return the correct ignored columns' do
          @p.audited_ignored_columns.must_equal [:title, :author_id]
        end
        
      end
      
    end
    
  end
  
  describe 'An audited Model :Author' do
    before do
      Author.plugin(:audited, only: :name)
    end
    
    describe 'Class Methods' do
      
      describe 'Author.audited_versions?' do
        before do
          ::AuditLog.where(model_type: 'Author').delete
        end
        
        it 'should return false when no versions have been created' do
          # skip
          Author.audited_versions?.must_equal false
        end
        
        it 'should return true if one version have been created' do
          a = Author.create(name: 'Kematzy')
          a.versions.count.must_equal 1
          Author.audited_versions?.must_equal true
        end
        
        it 'should return true if multiple versions have been created' do
          Author.audited_versions.count.must_equal 0
          
          a = Author.create(name: 'Kematzy')
          a.versions.count.must_equal 1
          Author.audited_versions.count.must_equal 1
          
          
          a.name = 'Kematzy 2'
          a.save
          Author.audited_versions.count.must_equal 2
          # forcing uncached query here
          a.versions(true).count.must_equal 2
          
          
          a.update(name: 'Kematzy 3')
          Author.audited_versions.count.must_equal 3
          # forcing uncached query here
          a.versions(true).count.must_equal 3
          
          
          a.set_fields({name: 'Kematzy 4'}, [:name], missing: :skip)
          a.save
          
          Author.audited_versions.count.must_equal 4
          # forcing uncached query here
          a.versions(true).count.must_equal 4
          
          Author.audited_versions?.must_equal true
        end
        
      end
      
      describe 'Author.audited_versions' do
        before do
          ::AuditLog.where(model_type: 'Author').delete
        end
        
        describe 'without options' do
          
          it 'should return an empty array when no versions exists' do
            Author.audited_versions.must_equal []
          end
          
          it 'should return an array of versions if one version have been created' do
            a = Author.create(name: 'Kematzy')
            Author.audited_versions.wont_be_empty 
            al = Author.audited_versions.first
            # al.must_equal ''
            al.must_be_kind_of(::AuditLog)
            al.model_type.must_equal 'Author'
            al.model_pk.must_equal a.id
          end
          
          # it 'shouldadasfa' do
          #   Author.first.methods.sort.must_equal ''
          # end
          
        end
        
        describe 'with options' do
          before do
            @u = User.create(username: 'johnblogs', name: 'John Blogs', email: 'john@blogs.com')
          end
          
          it 'should ' do
            $current_user = @u
            a = Author.create(name: 'Kematzy')
            v = a.versions.first
            v.username.must_equal 'johnblogs'
            $current_user = User[1]
          end
          
          it 'should ' do
            # current_user.must_equal ''
            $current_user = User[2]  # jane
            
            a = Author.create(name: 'Kematzy')
            v = a.versions.first
            v.username.must_equal 'janeblogs'
            $current_user = User[1]
          end
          
        end
        
      end
      
      describe 'something' do
        
      end
      
    end
    
    describe 'Instance Methods' do
      
      
    end
    
    describe 'should have associated versions' do
      
      it { assert_association_one_to_many(Author.new, :versions) }
      
      it 'should return 0 when no version have been saved' do
        
        # m.versions.count.must_equal 1
        # Author.associations.must_equal 'dadfas'
        # Author.association_reflection(:versions).must_equal 'dafdass'
        # m.associations.each do |a|
        #   m.associations_reflection(a).must_equal 'd'
        # end
        
        
        # assert_association_one_to_many(m, :version)
      end
      
      
    end
    
  end
  
  
  describe 'with Custom user method' do
    before do
      Author.plugin(:audited, only: :name, user_method: :audited_user)
    end
    
    it 'should' do
      # ::AuditLog.audited_current_user_method = :audited_user
      a = Author.create(name: 'Kematzy')
      # a.versions.must_equal ''
      v = a.versions.first
      v.username.must_equal 'auditeduser'
      # ::AuditLog.audited_current_user_method = :current_user
    end
  
  end
  
  
  
end