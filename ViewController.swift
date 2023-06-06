import UIKit
import SnapKit

class ViewController: UIViewController {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = "阿克汉山东科技阿圣诞节阿卡莎大手机卡等哈手机卡等哈就"
        return label
    }()

    private let animationView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 15
        return view
    }()

    private let rightView: UIView = {
        let view = UIView()
        view.backgroundColor = .cyan
        return view
    }()

    private var postCheckLayer: CAShapeLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        makeUI()

        animationView
            .addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(animationEvent)
            ))
    }

    @objc private func animationEvent() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self else { return }
            animationView.layer.bounds.size.width = 30
            animationView.layer.cornerRadius = 15
            animationView.layer.masksToBounds = true
        } completion: { [weak self] isComplete in
            if isComplete {
                guard let self else { return }
                let checkmarkLayer = CAShapeLayer()
                checkmarkLayer.strokeColor = UIColor.green.cgColor
                checkmarkLayer.lineWidth = 3.0
                checkmarkLayer.fillColor = UIColor.clear.cgColor
                animationView.layer.addSublayer(checkmarkLayer)
                postCheckLayer = checkmarkLayer

                let checkmarkPath = UIBezierPath()
                checkmarkPath.move(to: CGPoint(x: 8, y: 12))
                checkmarkPath.addLine(to: CGPoint(x: 13, y: 20))
                checkmarkPath.addLine(to: CGPoint(x: 23, y: 10))
                checkmarkLayer.path = checkmarkPath.cgPath

                let checkmarkAnimation = CABasicAnimation(keyPath: "strokeEnd")
                checkmarkAnimation.duration = 1
                checkmarkAnimation.delegate = self
                checkmarkAnimation.fromValue = 0.0
                checkmarkAnimation.toValue = 1.0
                checkmarkAnimation.setValue("postCheck", forKey: "animationIdentifier")
                checkmarkLayer.add(checkmarkAnimation, forKey: "postCheck")
            }
        }
    }

    private func makeUI() {
        view.addSubview(titleLabel)
        view.addSubview(animationView)
        view.addSubview(rightView)

        animationView.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(30)
            $0.top.equalToSuperview().offset(100)
            $0.trailing.equalTo(rightView.snp.leading).offset(-30)
        }

        rightView.snp.makeConstraints {
            $0.width.equalTo(10)
            $0.height.equalTo(30)
            $0.trailing.equalToSuperview().offset(-10)
            $0.centerY.equalTo(animationView)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.lessThanOrEqualTo(animationView.snp.leading).offset(-10)
            $0.centerY.equalTo(animationView)
            $0.height.equalTo(30)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        animationView.layer.removeAllAnimations()
        rightView.layer.removeAllAnimations()

        postCheckLayer?.removeFromSuperlayer()
        animationView.isHidden = false
        animationView.alpha = 1
        animationView.layer.bounds.size.width = 80
    }
}

extension ViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let identifier = anim.value(forKey: "animationIdentifier") as? String {
            if identifier == "postCheck" {
                // 抛物线动画
                let curvePath = UIBezierPath()
                curvePath.move(to: animationView.center)
                curvePath.addQuadCurve(to: rightView.center, controlPoint: CGPoint(x: (animationView.center.x + rightView.center.x) / 2, y: animationView.center.y - 30))

                let parabolicAnimation = CAKeyframeAnimation(keyPath: "position")
                parabolicAnimation.path = curvePath.cgPath
                parabolicAnimation.calculationMode = .cubic
                parabolicAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

                // 缩小动画
                let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                scaleAnimation.fromValue = 1.0
                scaleAnimation.toValue = 0.0

                // 透明度
                let opacityAnimation = CABasicAnimation(keyPath: "opacity")
                opacityAnimation.fromValue = 1.0
                opacityAnimation.toValue = 0.0

                // 创建动画组
                let animationGroup = CAAnimationGroup()
                animationGroup.animations = [parabolicAnimation, scaleAnimation, opacityAnimation]
                animationGroup.duration = 1.0
                animationGroup.setValue("scaleAnimation", forKey: "animationIdentifier")
                animationGroup.delegate = self
                animationView.layer.add(animationGroup, forKey: "animationGroup")
            } else if identifier == "scaleAnimation" {
                animationView.isHidden = true
                let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                scaleAnimation.fromValue = 1.0
                scaleAnimation.toValue = 1.2
                scaleAnimation.duration = 0.3
                scaleAnimation.autoreverses = true
                rightView.layer.add(scaleAnimation, forKey: "scaleAnimation")
            }
        }
    }
}
