import Ably

extension QueryOptions {
    func toDictionary() -> [String: String] {
        var dict: [String: String] = [:]
        
        if let start = start {
            dict["start"] = "\(start)"
        }
        
        if let end = end {
            dict["end"] = "\(end)"
        }
        
        if let limit = limit {
            dict["limit"] = "\(limit)"
        }
        if let orderBy = orderBy {
            switch orderBy {
            case .oldestFirst:
                dict["direction"] = "forwards"
            case .newestFirst:
                dict["direction"] = "backwards"
            }
        }
        
        if let fromSerial = fromSerial {
            dict["fromSerial"] = fromSerial
        }

        return dict
    }
}

final class ChatAPI: Sendable {
    private let rest: ARTRest
    private let realtime: RealtimeClient
    private let apiProtocolVersion: Int = 3
    
    init(rest: ARTRest, realtime: RealtimeClient) {
        self.rest = rest
        self.realtime = realtime
    }

    func getMessages(roomId: String, params: QueryOptions) async throws -> any PaginatedResult<Message> {
        let endpoint = "/chat/v1/rooms/\(roomId)/messages"
        let response: any PaginatedResult<Message> = try await makeAuthorizedPaginatedRequest(endpoint, params: params.toDictionary())
        return response
    }

    func sendMessage(roomId: String, params: SendMessageParams) async throws -> Message {
        let endpoint = "/chat/v1/rooms/\(roomId)/messages"
        var body: [String: Any] = ["text": params.text]
        
        if let metadata = params.metadata {
            body["metadata"] = metadata
        }
        
        if let headers = params.headers {
            body["headers"] = headers
        }
        
        return try await makeAuthorizedRequest(endpoint, method: "POST", body: body)
    }

    func getOccupancy(roomId: String) async throws -> OccupancyEvent {
        let endpoint = "/chat/v1/rooms/\(roomId)/occupancy"
        return try await makeAuthorizedRequest(endpoint, method: "GET")
    }
    
    // TODO - handle returning message in the caller instead of in this method... it shouldn't know about concrete Message type.
    private func makeAuthorizedRequest<RES: Codable>(_ url: String, method: String, body: [String: Any]? = nil) async throws -> RES {
        // Create an ARTHTTPPaginatedResponse using ARTRealtime.request
        if #available(macOS 13.0.0, *) {
            return try await withCheckedThrowingContinuation { continuation in
                do {
                    try rest.request(method, path: url, params: [:], body: body, headers: ["protocol": String(apiProtocolVersion)], callback: { paginatedResponse, error  in
                                   
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        do {
                            if let rawItems = paginatedResponse?.items.first {
                                let message = Message(timeserial: rawItems["timeserial"] as! String, clientID: self.realtime.clientId ?? "", roomID: "umairsDemoRoom1", text: body?["text"] as! String, createdAt: rawItems["createdAt"] as? Date, metadata: [:], headers: [:])
                                continuation.resume(returning: message as! RES)
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        } else {
            // Fallback on earlier versions
            throw ARTErrorInfo.create(withCode: 501, status: 0, message: "Unsupported macOS version")
        }
    }
    
    private func makeAuthorizedPaginatedRequest<RES: Codable & Sendable>(
        _ url: String,
        params: [String: String]? = nil,
        body: [String: Any]? = nil
    ) async throws -> any PaginatedResult<RES> {
        if #available(macOS 13.0.0, *) {
            if #available(iOS 16.0.0, *) {
                return try await withCheckedThrowingContinuation { continuation in
                    do {
                        try rest.request("GET", path: url, params: params, body: nil, headers: ["protocol": String(apiProtocolVersion)], callback: { paginatedResponse, error  in
                            
                            ARTHTTPPaginatedCallbackWrapper<RES>(callback: (paginatedResponse, error)).handleResponse(continuation: continuation)
                        })
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        } else {
            // Fallback on earlier versions
            throw ARTErrorInfo.create(withCode: 501, status: 0, message: "Unsupported macOS version")
        }
    }
}

@available(macOS 13.0.0, *)
struct ARTHTTPPaginatedCallbackWrapper<RES: Codable & Sendable> {
    let callback: (ARTHTTPPaginatedResponse?, ARTErrorInfo?)
    
    init(callback: (ARTHTTPPaginatedResponse?, ARTErrorInfo?)) {
        self.callback = callback
    }
    
    // Method to handle the response and convert to PaginatedResultWrapper
    @available(iOS 16.0.0, *)
    func handleResponse(continuation: CheckedContinuation<any PaginatedResult<RES>, any Error>) {
        // Handle the response and error
        if let error = callback.1 {
            continuation.resume(throwing: ARTErrorInfo.create(withCode: error.code, status: error.statusCode, message: error.message))
            return
        }
        
        guard let paginatedResponse = callback.0, paginatedResponse.statusCode == 200 else {
            continuation.resume(throwing: ARTErrorInfo.createUnknownError())
            return
        }
        
        do {
            if let rawItems = paginatedResponse.items as? [NSDictionary] {
                let jsonData = try JSONSerialization.data(withJSONObject: rawItems, options: [])
                let decodedData = try JSONDecoder().decode([RES].self, from: jsonData)
                let result = paginatedResponse.toPaginatedResult(items: decodedData)
                continuation.resume(returning: result)
            }
        } catch {
            continuation.resume(throwing: error)

        }
    }
}

extension ARTHTTPPaginatedResponse {
    func toPaginatedResult<T: Codable & Sendable>(items: [T]) -> PaginatedResultWrapper<T>{
        
        return PaginatedResultWrapper(paginatedResponse: self, items: items)
    }
}

// Define a concrete implementation of the PaginatedResult protocol
public final class PaginatedResultWrapper<T: Codable & Sendable>: PaginatedResult {
    public typealias T = T
    
    public let items: [T]
    public let hasNext: Bool
    public let isLast: Bool
    private let paginatedResponse: ARTHTTPPaginatedResponse
    
    public init(paginatedResponse: ARTHTTPPaginatedResponse, items: [T]) {
        self.items = items
        self.hasNext = paginatedResponse.hasNext
        self.isLast = paginatedResponse.isLast
        self.paginatedResponse = paginatedResponse
    }
    
    // Asynchronously fetch the next page if available
    public var next: (any PaginatedResult<T>)? {
        get async throws {
            if #available(macOS 13.0.0, *) {
                return try await withCheckedThrowingContinuation { continuation in
                    paginatedResponse.next { paginatedResponse, error in
                        ARTHTTPPaginatedCallbackWrapper(callback: (paginatedResponse, error)).handleResponse(continuation: continuation)
                    }
                }
            } else {
                return nil
            }
        }
    }
    
    // Asynchronously fetch the first page
    public var first: any PaginatedResult<T> {
        get async throws {
            if #available(macOS 13.0.0, *) {
                return try await withCheckedThrowingContinuation { continuation in
                    paginatedResponse.first { paginatedResponse, error in
                        ARTHTTPPaginatedCallbackWrapper(callback: (paginatedResponse, error)).handleResponse(continuation: continuation)
                    }
                }
            } else {
                throw fatalError()
            }
        }
    }
    
    // Asynchronously fetch the current page
    public var current: any PaginatedResult<T> {
        get async throws {
            if #available(macOS 13.0.0, *) {
                return try await withCheckedThrowingContinuation { continuation in
                    continuation.resume(returning: self)
                }
            } else {
                throw fatalError()
            }
        }
    }
}
