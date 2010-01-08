$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'API')
require 'test/unit'

require 'net/http'

# This is a mock class that pretends to be a Net::HTTPResponse. It is called from some of the
# tests to fake the network interaction with the server.
class MockHTTPResponse

    attr_reader :code, :body

    def initialize(suffix)
        case suffix
            when 'node/1'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <node id="1" version="1" lat="48.1" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
</osm>
}
            when 'node/1/ways'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <way id="1" version="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" uid="1" user="u">
    <nd ref="1"/>
    <nd ref="2"/>
    <nd ref="3"/>
    <tag k="created_by" v="osmeditor2"/>
    <tag k="highway" v="residential"/>
  </way>
</osm>
}

            when 'node/1/relations'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <relation id="1" version="1" visible="true" timestamp="2007-07-24T16:18:51+01:00" uid="1" user="u">
    <member type="node" ref="1" role=""/>
    <member type="way" ref="1" role=""/>
    <member type="way" ref="2" role=""/>
    <tag k="type" v="something"/>
  </relation>
</osm>
}

            when 'node/1/history'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <node id="1" lat="55.05996" lon="27.05581" changeset="687909" user="wildMan" uid="21417" visible="true" timestamp="2008-01-24T17:13:58Z" version="1">
    <tag k="place" v="hamlet"/>
    <tag k="name" v="Сарапоны"/>
    <tag k="created_by" v="JOSM"/>
  </node>
  <node id="1" lat="55.05996" lon="27.05581" changeset="1809065" user="jekhor" uid="29431" visible="true" timestamp="2009-07-12T17:41:19Z" version="2">
    <tag k="place" v="village"/>
    <tag k="name" v="Сарапоны"/>
    <tag k="created_by" v="JOSM"/>
  </node>
  <node id="1" lat="55.05996" lon="27.05581" changeset="2205356" user="jekhor" uid="29431" visible="true" timestamp="2009-08-19T20:53:46Z" version="3">
    <tag k="place" v="hamlet"/>
    <tag k="name" v="Сарапоны"/>
  </node>
</osm>
}

            when 'node/2'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <node id="1" version="1" lat="48.1" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
  <node id="2" version="1" lat="48.2" lon="8.2" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
</osm>
}
            when 'way/1'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <way id="1" version="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" uid="1" user="u">
    <nd ref="1"/>
    <nd ref="2"/>
    <nd ref="3"/>
    <tag k="created_by" v="osmeditor2"/>
    <tag k="highway" v="residential"/>
  </way>
</osm>
}
            when 'way/1/full'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <node id="1" version="1" lat="48.1" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
  <node id="2" version="1" lat="48.2" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00"/>
  <node id="3" version="1" lat="48.3" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00"/>
  <way id="1" version="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" uid="1" user="u">
    <nd ref="1"/>
    <nd ref="2"/>
    <nd ref="3"/>
    <tag k="created_by" v="osmeditor2"/>
    <tag k="highway" v="residential"/>
  </way>
</osm>
}
            when 'way/25327522/full'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <node id="275936385" lat="53.9037318" lon="27.5585461" version="4" changeset="2063210" user="timerov" uid="109654" visible="true" timestamp="2009-08-07T09:17:00Z"/>
  <node id="275936387" lat="53.9036232" lon="27.5582845" version="3" changeset="2063210" user="timerov" uid="109654" visible="true" timestamp="2009-08-07T09:17:00Z"/>
  <node id="275936389" lat="53.9038222" lon="27.5580535" version="3" changeset="2063210" user="timerov" uid="109654" visible="true" timestamp="2009-08-07T09:17:00Z"/>
  <node id="275936392" lat="53.9039402" lon="27.5583495" version="3" changeset="2063210" user="timerov" uid="109654" visible="true" timestamp="2009-08-07T09:17:00Z"/>
  <node id="275936394" lat="53.9038792" lon="27.5584295" version="3" changeset="2063210" user="timerov" uid="109654" visible="true" timestamp="2009-08-07T09:17:00Z"/>
  <node id="275936396" lat="53.9038602" lon="27.5583915" version="3" changeset="2063210" user="timerov" uid="109654" visible="true" timestamp="2009-08-07T09:17:00Z"/>
  <node id="275936399" lat="53.9038129" lon="27.5584456" version="4" changeset="2063210" user="timerov" uid="109654" visible="true" timestamp="2009-08-07T09:17:00Z"/>
  <way id="25327522" visible="true" timestamp="2009-04-10T00:56:33Z" version="5" changeset="364461" user="osm-belarus" uid="86479">
    <nd ref="275936385"/>
    <nd ref="275936387"/>
    <nd ref="275936389"/>
    <nd ref="275936392"/>
    <nd ref="275936394"/>
    <nd ref="275936396"/>
    <nd ref="275936399"/>
    <nd ref="275936385"/>
    <tag k="addr:housenumber" v="3"/>
    <tag k="addr:street" v="Энгельса ул."/>
    <tag k="building" v="yes"/>
  </way>
                        </osm>
}
            when 'way/2'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <way id="1" version="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" uid="1" user="u">
    <nd ref="1"/>
    <nd ref="2"/>
    <nd ref="3"/>
    <tag k="created_by" v="osmeditor2"/>
    <tag k="highway" v="residential"/>
  </way>
  <way id="2" version="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" uid="1" user="u">
    <nd ref="4"/>
    <nd ref="5"/>
    <nd ref="6"/>
    <tag k="created_by" v="osmeditor2"/>
    <tag k="highway" v="residential"/>
  </way>
</osm>
}
            when 'relation/1'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <relation id="1" version="1" visible="true" timestamp="2007-07-24T16:18:51+01:00" uid="1" user="u">
    <member type="way" ref="1" role=""/>
    <member type="way" ref="2" role=""/>
    <tag k="type" v="something"/>
  </relation>
</osm>
}
            when 'relation/1/full'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <node id="1" version="1" lat="48.1" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
  <node id="2" version="1" lat="48.2" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00"/>
  <node id="3" version="1" lat="48.3" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00"/>
  <node id="4" version="1" lat="48.4" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00"/>
  <node id="5" version="1" lat="48.5" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00"/>
  <node id="6" version="1" lat="48.6" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00"/>
  <way id="1" version="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" uid="1" user="u">
    <nd ref="1"/>
    <nd ref="2"/>
    <nd ref="3"/>
    <tag k="created_by" v="osmeditor2"/>
    <tag k="highway" v="residential"/>
  </way>
  <way id="2" version="1" visible="true" timestamp="2007-06-03T20:02:39+01:00" uid="1" user="u">
    <nd ref="4"/>
    <nd ref="5"/>
    <nd ref="6"/>
    <tag k="created_by" v="osmeditor2"/>
    <tag k="highway" v="residential"/>
  </way>
  <relation id="1" version="1" visible="true" timestamp="2007-07-24T16:18:51+01:00" uid="1" user="u">
    <member type="way" ref="1" role=""/>
    <member type="way" ref="2" role=""/>
    <tag k="type" v="something"/>
  </relation>
</osm>
}
            when 'relation/2'
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <relation id="1" version="1" visible="true" timestamp="2007-07-24T16:18:51+01:00" uid="1" user="u">
    <member type="way" ref="1" role=""/>
    <member type="way" ref="2" role=""/>
    <tag k="type" v="something"/>
  </relation>
  <relation id="2" version="1" visible="true" timestamp="2007-07-24T16:18:51+01:00" uid="1" user="u">
    <member type="way" ref="3" role=""/>
    <member type="way" ref="4" role=""/>
    <tag k="type" v="something"/>
  </relation>
</osm>
}
            when /^(node|way|relation)\/404(\/full|\/ways|\/relations|\/history)?$/
                @code = 404
                @body = ''
            when /^(node|way|relation)\/410(\/full|\/ways|\/relations|\/history)?$/
                @code = 410
                @body = ''
            when /^(node|way|relation)\/500(\/full|\/ways|\/relations|\/history)?$/
                @code = 500
                @body = ''
            when /^map\?bbox/
                @code = 200
                @body = %q{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server">
  <node id="1" version="1" lat="48.1" lon="8.1" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
  <node id="2" version="1" lat="48.2" lon="8.2" uid="1" user="u" visible="true" timestamp="2007-07-03T00:04:12+01:00">
    <tag k="created_by" v="JOSM"/>
  </node>
</osm>
}
            else
                raise ArgumentError.new("unknown parameter: '#{suffix}'")
        end
    end

end

class TestAPI < Test::Unit::TestCase

    def setup
        @api = OSM::API.new

        @mapi = OSM::API.new('http://mock/')
        def @mapi.get(suffix)
            MockHTTPResponse.new(suffix)
        end
    end

    def test_create_std
        assert_kind_of OSM::API, @api
        assert_equal 'http://www.openstreetmap.org/api/0.6/', @api.instance_variable_get(:@base_uri)
    end

    def test_create_uri
        api = OSM::API.new('http://localhost/')
        assert_kind_of OSM::API, api
        assert_equal 'http://localhost/', api.instance_variable_get(:@base_uri)
    end

    def test_get_object
        assert_raise ArgumentError do
            @mapi.get_object('foo', 1)
        end
    end

    # node

    def test_get_node_type_error
        assert_raise TypeError do
            @api.get_node('foo')
        end
        assert_raise TypeError do
            @api.get_node(-17)
        end
    end

    def test_get_node_200
        node = @mapi.get_node(1)
        assert_kind_of OSM::Node, node
        assert_equal 1, node.id
        assert_equal '48.1', node.lat
        assert_equal '8.1', node.lon
        assert_equal 'u', node.user
    end

    def test_get_node_too_many_objects
        assert_raise OSM::APITooManyObjects do
            @mapi.get_node(2)
        end
    end

    def test_get_node_404
        assert_raise OSM::APINotFound do
            @mapi.get_node(404)
        end
    end

    def test_get_node_410
        assert_raise OSM::APIGone do
            @mapi.get_node(410)
        end
    end

    def test_get_node_500
        assert_raise OSM::APIServerError do
            @mapi.get_node(500)
        end
    end

    def test_get_node_history
        objs = @mapi.get_history('node', 1)
        assert_equal 3, objs.size
        objs.each {|o|
            assert_kind_of OSM::Node, o
            assert_equal 1, o.id
        }
    end

    def test_get_node_history_404
        assert_raise OSM::APINotFound do
            @mapi.get_history('node', 404)
        end
    end

    def test_get_node_history_410
        assert_raise OSM::APIGone do
            @mapi.get_history('node', 410)
        end
    end

    def test_get_node_history_500
        assert_raise OSM::APIServerError do
            @mapi.get_history('node', 500)
        end
    end

    # way

    def test_get_way_type_error
        assert_raise TypeError do
            @api.get_way('foo')
        end
        assert_raise TypeError do
            @api.get_way(-17)
        end
    end

    def test_get_way_200
        way = @mapi.get_way(1)
        assert_kind_of OSM::Way, way
        assert_equal 1, way.id
        assert_equal 'u', way.user
    end

    def test_get_way_404
        assert_raise OSM::APINotFound do
            @mapi.get_way(404)
        end
    end

    def test_get_way_410
        assert_raise OSM::APIGone do
            @mapi.get_way(410)
        end
    end

    def test_get_way_500
        assert_raise OSM::APIServerError do
            @mapi.get_way(500)
        end
    end

    def test_get_full_way_200
        objs = @mapi.get_full_way(1)
        assert_kind_of OSM::Node, objs[0]
        assert_kind_of OSM::Node, objs[1]
        assert_kind_of OSM::Node, objs[2]
        assert_kind_of OSM::Way, objs[3]
        way = objs[3]
        assert_equal 1, way.id
        assert_equal 'u', way.user
        assert_equal 3, way.nodes.size
        assert_equal 1, objs[0].id
        assert_equal 2, objs[1].id
        assert_equal 3, objs[2].id
    end

    def test_get_full_way_404
        assert_raise OSM::APINotFound do
            @mapi.get_full_way(404)
        end
    end

    def test_get_full_way_410
        assert_raise OSM::APIGone do
            @mapi.get_full_way(410)
        end
    end

    def test_get_full_way_500
        assert_raise OSM::APIServerError do
            @mapi.get_full_way(500)
        end
    end

    def test_get_ways_using_node_200
        objs = @mapi.get_ways_using_node(1)
        assert_equal 1, objs.size
        assert_kind_of OSM::Way, objs[0]
        way = objs[0]
        assert_equal 1, way.id
        assert_equal 3, way.nodes.size
    end

    def test_get_ways_using_node_404
        assert_raise OSM::APINotFound do
            @mapi.get_ways_using_node(404)
        end
    end

    def test_get_ways_using_node_410
        assert_raise OSM::APIGone do
            @mapi.get_ways_using_node(410)
        end
    end

    def test_get_ways_using_node_500
        assert_raise OSM::APIServerError do
            @mapi.get_ways_using_node(500)
        end
    end

    # relation

    def test_get_relation_type_error
        assert_raise TypeError do
            @api.get_relation('foo')
        end
        assert_raise TypeError do
            @api.get_relation(-17)
        end
    end

    def test_get_relation_200
        relation = @mapi.get_relation(1)
        assert_kind_of OSM::Relation, relation
        assert_equal 1, relation.id
        assert_equal 'u', relation.user
    end

    def test_get_relation_404
        assert_raise OSM::APINotFound do
            @mapi.get_relation(404)
        end
    end

    def test_get_relation_410
        assert_raise OSM::APIGone do
            @mapi.get_relation(410)
        end
    end

    def test_get_relation_500
        assert_raise OSM::APIServerError do
            @mapi.get_relation(500)
        end
    end

    def test_get_full_relation_200
        objs = @mapi.get_full_relation(1)
        assert_equal 9, objs.size
        objs[0..5].each_with_index {|o, i|
            assert_kind_of OSM::Node, o
            assert_equal i + 1, o.id
        }
        assert_kind_of OSM::Way, objs[6]
        assert_kind_of OSM::Way, objs[7]
        assert_kind_of OSM::Relation, objs[8]
        relation = objs[8]
        assert_equal 1, relation.id
        assert_equal 'u', relation.user
        assert_equal 2, relation.members.size
    end

    def test_get_full_relation_404
        assert_raise OSM::APINotFound do
            @mapi.get_full_relation(404)
        end
    end

    def test_get_full_relation_410
        assert_raise OSM::APIGone do
            @mapi.get_full_relation(410)
        end
    end

    def test_get_full_relation_500
        assert_raise OSM::APIServerError do
            @mapi.get_full_relation(500)
        end
    end

    def test_get_relations_referring_to_object
        objs = @mapi.get_relations_referring_to_object('node', 1)
        assert_equal 1, objs.size
        relation = objs[0]
        assert_kind_of OSM::Relation, relation
        assert_equal 3, relation.members.size
        node = OSM::Node.new(1, 'somebody', '2007-02-20T10:29:49+00:00', 8.5, 47.5, 5, 3)
        objs1 = node.get_relations_from_api(@mapi)
        assert_equal objs[0], objs1[0]
    end

    def test_get_relations_referring_to_object_404
        assert_raise OSM::APINotFound do
            @mapi.get_relations_referring_to_object('node', 404)
        end
    end

    def test_get_relations_referring_to_object_410
        assert_raise OSM::APIGone do
            @mapi.get_relations_referring_to_object('node', 410)
        end
    end

    def test_get_relations_referring_to_object_500
        assert_raise OSM::APIServerError do
            @mapi.get_relations_referring_to_object('node', 500)
        end
    end

    def test_get_bbox_fail
        assert_raise TypeError do
            @api.get_bbox('a', 'b', 'c', 'd')
        end
        assert_raise TypeError do
            @api.get_bbox(1, 2, 3, -200)
        end
        assert_raise TypeError do
            @api.get_bbox(1, 2, -200, 3)
        end
        assert_raise TypeError do
            @api.get_bbox(1, -200, 2, 3)
        end
        assert_raise TypeError do
            @api.get_bbox(-200, 1, 2, 3)
        end
    end

    def test_get_bbox
        db = @mapi.get_bbox(8.1, 48.1, 8.2, 48.2)
        assert_kind_of OSM::Database, db
        assert_equal "48.1", db.get_node(1).lat
        assert_equal "8.2", db.get_node(2).lon
    end

end

