$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects')
require 'test/unit'

class TestMembers < Test::Unit::TestCase

    def test_node
        member = OSM::Member.new('node', 17, 'foo')
        assert_equal 'node', member.type
        assert_equal 17, member.ref
        assert_equal 'foo', member.role
    end

    def test_way
        member = OSM::Member.new('way', 17)
        assert_equal 'way', member.type
        assert_equal 17, member.ref
        assert_equal '', member.role
    end

    def test_relation
        member = OSM::Member.new('relation', 17, 'foo')
        assert_equal 'relation', member.type
        assert_equal 17, member.ref
        assert_equal 'foo', member.role
    end

    def test_equality
        member1 = OSM::Member.new('node', 17, 'foo')
        member2 = OSM::Member.new('node', 17, 'foo')
        member3 = OSM::Member.new('way', 17, 'foo')
        member4 = OSM::Member.new('node', 18, 'foo')
        member5 = OSM::Member.new('node', 17, 'bar')

        assert_equal member1, member2
        assert_not_equal member1, member3
        assert_not_equal member1, member4
        assert_not_equal member1, member5
    end

    def test_fail
        assert_raise ArgumentError do
            OSM::Member.new('unknown', 17, 'foo')
        end
    end

end
