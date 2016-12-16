import UIKit

typealias Filter = (CIImage) -> CIImage

func blur(radius: Double) -> Filter {
    return {
        image in
        let parameters:[String : Any] = [
                kCIInputRadiusKey: radius,
                kCIInputImageKey: image
        ]
        guard let filter = CIFilter(name: "CIGaussianBlur", withInputParameters: parameters) else {
            fatalError()
        }
        guard let outputImage = filter.outputImage else {
            fatalError()
        }
        return outputImage
    }
}

func colorGenerator(_ color: UIColor) -> Filter {
    return { _ in
        let parameters = [kCIInputColorKey: CIColor(color: color)]
        guard let filter = CIFilter(name: "CIConstantColorGenerator", withInputParameters: parameters) else {
            fatalError()
        }
        guard let outputImage = filter.outputImage else {
            fatalError()
        }
        return outputImage
    }
}

func compositeSourceOver(overlay: CIImage) -> Filter {
    return { image in
        let parameters: [String: Any] = [
            kCIInputBackgroundImageKey: image,
            kCIInputImageKey: overlay
        ]
        guard let filter = CIFilter(name: "CISourceOverCompositing", withInputParameters: parameters) else {
            fatalError()
        }
        guard let outputImage = filter.outputImage else {
            fatalError()
        }
        let cropRect = image.extent
        return outputImage.cropping(to: cropRect)
    }
}

func colorOverlay(_ color: UIColor) -> Filter {
    return { image in
        let overlay = colorGenerator(color)(image)
        return compositeSourceOver(overlay: overlay)(image)
    }
}

let url = URL(string: "http://www.objc.io/images/covers/16.jpg")!
let image = CIImage(contentsOf: url)!

let blurRadius = 10.0
let overlayColor = UIColor.red.withAlphaComponent(0.2)
let blurredImage = blur(radius: blurRadius)(image)
let overlaidImage = colorOverlay(overlayColor)(blurredImage)

infix operator >>> : MultiplicationPrecedence

func >>> (filter1: @escaping Filter, _ filter2: @escaping Filter) -> Filter {
    return { image in filter2(filter1(image)) }
}

let myFilter2 = blur(radius: blurRadius) >>> colorOverlay(overlayColor)



