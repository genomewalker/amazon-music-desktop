import XCTest
@testable import AmazonMusicDesktop

final class NowPlayingPayloadTests: XCTestCase {
    func testDecodePayload() throws {
        let json = """
        {
          "title": "Track",
          "artist": "Artist",
          "artworkURL": "https://example.com/art.png",
          "isPlaying": true
        }
        """
        let data = Data(json.utf8)
        let payload = try JSONDecoder().decode(NowPlayingPayload.self, from: data)

        XCTAssertEqual(payload.title, "Track")
        XCTAssertEqual(payload.artist, "Artist")
        XCTAssertEqual(payload.artworkURL, "https://example.com/art.png")
        XCTAssertTrue(payload.isPlaying)
    }

    func testDecodePayloadWithMissingFieldsFails() throws {
        let json = """
        {
          "title": "Track",
          "artist": "Artist"
        }
        """
        let data = Data(json.utf8)

        XCTAssertThrowsError(try JSONDecoder().decode(NowPlayingPayload.self, from: data))
    }
}
