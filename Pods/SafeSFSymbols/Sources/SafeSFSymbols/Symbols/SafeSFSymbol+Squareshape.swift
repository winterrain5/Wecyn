// The MIT License (MIT)
// Copyright © 2023 Sparrow Code LTD (https://sparrowcode.io, hello@sparrowcode.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

extension SafeSFSymbol {

	@available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, watchOS 7.0, *)
	public static var squareshape: Squareshape { .init(name: "squareshape") }

	open class Squareshape: SafeSFSymbol {

		@available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, watchOS 7.0, *)
		open var controlhandlesOnSquareshapeControlhandles: SafeSFSymbol { ext(.start + ".controlhandles.on.squareshape.controlhandles") }

		@available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, watchOS 9.0, *)
		open var dottedSplit_2x2: SafeSFSymbol { ext(.start + ".dotted.split.2x2") }
		@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
		open var dottedSquareshape: SafeSFSymbol { ext(.start + ".dotted.squareshape") }

		@available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, watchOS 7.0, *)
		open var fill: SafeSFSymbol { ext(.start.fill) }

		@available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, watchOS 7.0, *)
		open var split_2x2: SafeSFSymbol { ext(.start + ".split.2x2") }
		@available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, watchOS 7.0, *)
		open var split_2x2Dotted: SafeSFSymbol { ext(.start + ".split.2x2.dotted") }
		@available(iOS 14.0, macOS 11.0, tvOS 14.0, visionOS 1.0, watchOS 7.0, *)
		open var split_3x3: SafeSFSymbol { ext(.start + ".split.3x3") }

		@available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, watchOS 10.0, *)
		open var squareshapeDotted: SafeSFSymbol { ext(.start + ".squareshape.dotted") }
	}
}