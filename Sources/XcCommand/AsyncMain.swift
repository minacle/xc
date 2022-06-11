#if swift(<5.6)
import ArgumentParser

@main
enum AsyncMain: AsyncMainProtocol {

    typealias Command = XcCommand
}
#endif
