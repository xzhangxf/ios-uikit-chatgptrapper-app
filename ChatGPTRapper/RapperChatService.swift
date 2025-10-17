//
//  RapperChatService.swift
//  ChatGPTRapper
//
//  Created by Xufeng Zhang on 17/10/25.
//

import Foundation
import OpenAI


enum RapperChatError: LocalizedError {
    case missingAPIKey
    case emptyInput
    case emptyResponse
    
    var errorDescription: String?{
        switch self {
        case .emptyInput:
            return "Input cannot be empty."
        case .emptyResponse:
            return "No response from the chat service."
        case .missingAPIKey:
            return "Missing API key."
        }
    }
}

class RapperChatService {
    let openAI: OpenAI
    let systemPrompt: String = "You are Ah Beng GPT, a larger-than-life hip-hop hype artist. Answer with playful, witty rap bars packed with internal rhymes, Singlish slang, and good vibes. Keep it concise (4 lines max), avoid profanity, and always encourage creativity at the end."
    
    
    init(apiKey: String? = nil)  throws {
        //let tokenArg = apiKey
        let tokenEnv = ProcessInfo.processInfo.environment["OPEN_API_KEY"]
        //let tokeninfo = Bundle.main.object(forInfoDictionaryKey: "OpenAPIKey") as? String
        //print(tokenEnv!)
        guard let token = tokenEnv else {
            
            throw RapperChatError.missingAPIKey
        }
        self.openAI = OpenAI(apiToken: token)
    }
    
    func respond(to text: String) async throws ->String {
        let prompt = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else {
            throw RapperChatError.emptyInput
        }
//        let messages: [Chat] = [.system(.init(content: .textContent(systemPrompt))), .user(.init(content: .string(prompt)))]
//        let query = ChatQuery(
//            messages: messages,
//            model: .gpt5_mini,
//            temperature: 0.9
//        )
        let messages = [
              ChatQuery.ChatCompletionMessageParam.system(.init(content: .textContent(systemPrompt))),
              ChatQuery.ChatCompletionMessageParam.user(.init(content: .string(prompt)))
          ]

          let query = ChatQuery(
              messages: messages,
              model: .gpt5,
              temperature: 1
          )
        
        let result = try await openAI.chats(query: query)

        let textOut = (result.choices.first?.message.content ?? "")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        guard !textOut.isEmpty else { throw RapperChatError.emptyResponse }
        return textOut
    }
}


