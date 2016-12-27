import test = require('tape');
import xml = require('../lib/xml');

test(function(t) {
    t.deepEqual(
        xml.parse('<?xml version="1.0" encoding="utf-8" ?><foo><bar foo="foobar">&#169; foobar</bar><bar>foo<![CDATA[bar]]>baz</bar><bar foo="&lt;&gt;" />&lt;&gt;</foo>'),
        {
            xml: {
                version: "1.0",
                encoding: 'utf-8'
            },
            root: ['foo', {}, [
                ['bar', { foo: 'foobar' }, ['© foobar']],
                ['bar', {}, ['foo', 'bar', 'baz']],
                ['bar', { foo: '<>' }, []],
                '<>'
            ]],
        }
    );
    t.end();
});
