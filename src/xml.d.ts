declare namespace XmlParser {
    function parse(input: string, options?: Options): Result;

    class SyntaxError extends Error {
    }

    interface Result {
        xml: Xml;
        root: Element;
    }

    interface Xml {
        version: string;
        standalone?: string;
        encoding?: string;
    }

    interface Options {
        startRule?: string;
    }

    type Node = Element | string;

    // Uses tuple-like type because type alias does not allow circular references.
    // https://github.com/Microsoft/TypeScript/blob/master/doc/spec.md#333-tuple-types
    interface Element extends Array<string | { [key: string]: string } | Node[]> {
        0: string;
        1: { [key: string]: string };
        2: Node[];
    }
}

export = XmlParser;
